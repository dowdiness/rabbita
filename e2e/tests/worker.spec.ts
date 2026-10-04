import { expect, test, type Page } from '@playwright/test';

type ProbeRecord = {
  worker: Worker;
  url: string;
  posts: string[];
  received: string[];
  listeners: Map<string, Set<EventListenerOrEventListenerObject>>;
  terminated: boolean;
  failNextPost: boolean;
};

async function instrumentWorkers(page: Page) {
  await page.addInitScript(() => {
    const pendingTimeouts = new Set<number>();
    const nativeSetTimeout = window.setTimeout.bind(window);
    const nativeClearTimeout = window.clearTimeout.bind(window);
    window.setTimeout = ((handler, timeout, ...args) => {
      let timer = 0;
      timer = nativeSetTimeout((...callbackArgs: unknown[]) => {
        pendingTimeouts.delete(timer);
        if (typeof handler === 'function') handler(...callbackArgs);
        else if (typeof handler === 'string') window.eval(handler);
      }, timeout, ...args);
      pendingTimeouts.add(timer);
      return timer;
    }) as typeof window.setTimeout;
    window.clearTimeout = ((timer) => {
      pendingTimeouts.delete(timer);
      nativeClearTimeout(timer);
    }) as typeof window.clearTimeout;
    const NativeWorker = window.Worker;
    const probe = {
      constructorFailures: 0,
      records: [] as ProbeRecord[],
      get active() {
        return this.records.filter((record) => !record.terminated).length;
      },
      get listenerCount() {
        return this.records.reduce(
          (count, record) => count + [...record.listeners.values()].reduce((n, set) => n + set.size, 0),
          0,
        );
      },
      get timerCount() {
        return pendingTimeouts.size;
      },
      dispatch(index: number, type: string, data?: unknown) {
        const record = this.records[index];
        if (!record) throw new Error(`No Worker at index ${index}`);
        record.worker.dispatchEvent(type === 'message'
          ? new MessageEvent('message', { data })
          : new Event(type));
      },
    };
    Object.defineProperty(window, '__workerProbe', { value: probe });
    window.Worker = new Proxy(NativeWorker, {
      construct(Target, args: [string | URL, WorkerOptions?]) {
        const url = String(args[0]);
        if (new URL(url, window.location.href).searchParams.get('mode') === 'constructor') {
          probe.constructorFailures += 1;
          return Reflect.construct(Target, ['http://[invalid', args[1]]);
        }
        const worker = Reflect.construct(Target, args) as Worker;
        const record: ProbeRecord = {
          worker,
          url,
          posts: [],
          received: [],
          listeners: new Map(),
          terminated: false,
          failNextPost: false,
        };
        probe.records.push(record);
        const add = worker.addEventListener.bind(worker);
        const remove = worker.removeEventListener.bind(worker);
        add('message', (event) => record.received.push(String((event as MessageEvent).data)));
        const post = worker.postMessage.bind(worker);
        const terminate = worker.terminate.bind(worker);
        worker.addEventListener = ((type, listener, options) => {
          if (listener) {
            const listeners = record.listeners.get(type) ?? new Set();
            listeners.add(listener);
            record.listeners.set(type, listeners);
          }
          add(type, listener, options);
        }) as Worker['addEventListener'];
        worker.removeEventListener = ((type, listener, options) => {
          if (listener) record.listeners.get(type)?.delete(listener);
          remove(type, listener, options);
        }) as Worker['removeEventListener'];
        worker.postMessage = ((message, transfer) => {
          record.posts.push(typeof message === 'string' ? message : String(message));
          if (record.failNextPost) {
            record.failNextPost = false;
            // Ask the real browser structured-clone boundary to reject a function.
            return post(() => undefined);
          }
          post(message, transfer ?? []);
        }) as Worker['postMessage'];
        worker.terminate = (() => {
          if (!record.terminated) {
            record.terminated = true;
            terminate();
          }
        }) as Worker['terminate'];
        return worker;
      },
    });
  });
}

async function openWorkerFixture(page: Page) {
  await instrumentWorkers(page);
  await page.goto('/');
  await expect(page.getByText('status: connected via old tagger')).toBeVisible();
}

const frozenPages = new WeakSet<Page>();

async function openFrozenWorkerFixture(page: Page) {
  await page.clock.install({ time: new Date('2026-10-04T00:00:00Z') });
  await openWorkerFixture(page);
  frozenPages.add(page);
  await page.clock.pauseAt(new Date('2026-10-04T01:00:00Z'));
}

test.afterEach(async ({ page }) => {
  if (frozenPages.has(page)) await page.clock.resume();
});

async function inspectWorkers(page: Page) {
  return page.evaluate(() => {
    const state = (window as Window & { __workerProbe: { records: ProbeRecord[]; active: number; listenerCount: number; timerCount: number; constructorFailures: number } }).__workerProbe;
    return {
      records: state.records.map(({ url, posts, received, terminated }) => ({ url, posts, received, terminated })),
      active: state.active,
      listenerCount: state.listenerCount,
      timerCount: state.timerCount,
      constructorFailures: state.constructorFailures,
    };
  });
}

test('same local subscription key stays isolated across two state stores', async ({ page }) => {
  await openWorkerFixture(page);
  await page.getByRole('button', { name: 'Mount second Worker owner' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).active).toBe(2);
  const state = await inspectWorkers(page);
  expect(state.records).toHaveLength(2);
  await page.getByRole('button', { name: 'Send request' }).first().click();
  await expect(page.locator('#worker-results').first()).toContainText('work:one');
  await expect(page.locator('#worker-results').nth(1)).toHaveText('results: ');
  await page.getByRole('button', { name: 'Send request' }).nth(1).click();
  await expect(page.locator('#worker-results').nth(1)).toContainText('r1=1|work:one');
  await page.getByRole('button', { name: 'Send request' }).first().click();
  await expect(page.locator('#worker-results').first()).toContainText('r2=2|work:one');
});

test('real module Worker correlates concurrent work; retag does not restart it', async ({ page }) => {
  await openWorkerFixture(page);
  const original = await inspectWorkers(page);
  await page.getByRole('button', { name: 'Retag callbacks' }).click();
  await expect(page.getByText('tagger: new')).toBeVisible();
  await page.getByRole('button', { name: 'Send concurrent requests' }).click();
  await expect(page.locator('#worker-results')).toContainText('work:slow');
  await expect(page.locator('#worker-results')).toContainText('work:fast');
  const result = await page.locator('#worker-results').innerText();
  expect(result).toMatch(/r1=\d+\|work:slow/);
  expect(result).toMatch(/r2=\d+\|work:fast/);
  expect(result).toContain(';');
  const same_worker = await inspectWorkers(page);
  expect(same_worker.records).toHaveLength(1);
  expect(same_worker.active).toBe(1);
  expect(same_worker.records[0].url).toBe(original.records[0].url);
  await page.evaluate(() => {
    const probe = (window as Window & { __workerProbe: { dispatch(index: number, type: string): void } }).__workerProbe;
    probe.dispatch(0, 'messageerror');
  });
  await expect(page.getByText('status: failed: MessageError')).toBeVisible();
  await expect(page.locator('#old-events')).toHaveText('old events: 1');
  await expect(page.locator('#new-events')).toHaveText('new events: 1');
  const after_failure = await inspectWorkers(page);
  expect(after_failure.records).toHaveLength(1);
  expect(after_failure.active).toBe(0);
});

test('URL and generation replacement terminate each previous native Worker', async ({ page }) => {
  await openWorkerFixture(page);
  await page.getByRole('button', { name: 'Replace Worker URL' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records).toHaveLength(2);
  await page.getByRole('button', { name: 'Replace Worker generation' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records).toHaveLength(3);
  const state = await inspectWorkers(page);
  expect(state.records.slice(0, 2).every((record) => record.terminated)).toBe(true);
  expect(state.active).toBe(1);
});

test('a request command captured before replacement never posts to the new Worker', async ({ page }) => {
  await openWorkerFixture(page);
  await page.getByRole('button', { name: 'Queue old request and replace' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records).toHaveLength(2);
  await expect(page.locator('#worker-settlements')).toHaveText('settlements: 1');
  const state = await inspectWorkers(page);
  const requests = (record: { posts: string[] }) => record.posts.map((raw) => JSON.parse(raw)).filter((message) => message.kind === 'request');
  expect(requests(state.records[1])).toHaveLength(0);
});

test('duplicate replies settle once and invalid timeout is rejected before posting', async ({ page }) => {
  await openWorkerFixture(page);
  await page.getByRole('button', { name: 'Send duplicate-reply request' }).click();
  await expect(page.locator('#worker-results')).toContainText('work:duplicate');
  await expect.poll(async () => (await inspectWorkers(page)).records[0].received.length).toBeGreaterThanOrEqual(2);
  const duplicateResult = await page.locator('#worker-results').innerText();
  expect(duplicateResult.match(/r\d+=/g)).toHaveLength(1);
  await expect(page.locator('#worker-settlements')).toHaveText('settlements: 1');
  await page.getByRole('button', { name: 'Send invalid-timeout request' }).click();
  await expect(page.locator('#worker-results')).toContainText('InvalidTimeout');
  const state = await inspectWorkers(page);
  const requests = state.records[0].posts.map((raw) => JSON.parse(raw)).filter((message) => message.kind === 'request');
  expect(requests.some((message) => message.payload === 'work:invalid-timeout')).toBe(false);
});

test('application admission rejects a real old reply already queued before replacement', async ({ page }) => {
  await openFrozenWorkerFixture(page);
  const baseline = await inspectWorkers(page);
  await page.getByRole('button', { name: 'Send delayed-response request' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records[0].received.length).toBe(1);
  await page.clock.runFor(20);
  await expect(page.getByText('status: reply queued for domain admission')).toBeVisible();
  await expect.poll(async () => (await inspectWorkers(page)).timerCount).toBeGreaterThan(baseline.timerCount);
  await page.getByRole('button', { name: 'Replace Worker URL' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records).toHaveLength(2);
  await page.clock.runFor(150);
  await expect(page.locator('#worker-results')).toHaveText('results: ');
  await expect(page.locator('#worker-settlements')).toHaveText('settlements: 1');
});

test('constructor, runtime, malformed reply, messageerror, and post failures are observable', async ({ page }) => {
  await openWorkerFixture(page);
  await page.getByRole('button', { name: 'Use constructor-failing Worker' }).click();
  await expect(page.getByText('status: failed: ConstructionFailed')).toBeVisible();
  expect((await inspectWorkers(page)).constructorFailures).toBe(1);
  await page.getByRole('button', { name: 'Retag callbacks' }).click();
  expect((await inspectWorkers(page)).constructorFailures).toBe(1);
  await page.getByRole('button', { name: 'Use runtime-failing Worker' }).click();
  await expect(page.getByText('status: connected via new tagger')).toBeVisible();
  await page.getByRole('button', { name: 'Send request' }).click();
  await expect(page.getByText('status: failed: WorkerFailed')).toBeVisible();
  await page.getByRole('button', { name: 'Use malformed-reply Worker' }).click();
  await expect(page.getByText('status: connected via new tagger')).toBeVisible();
  await page.getByRole('button', { name: 'Send request' }).click();
  await expect(page.getByText('status: failed: InvalidMessage')).toBeVisible();
  await page.getByRole('button', { name: 'Replace Worker URL' }).click();
  await expect(page.getByText('status: connected via new tagger')).toBeVisible();
  await page.evaluate(() => {
    const records = (window as Window & { __workerProbe: { records: ProbeRecord[] } }).__workerProbe.records;
    records[records.length - 1].failNextPost = true;
  });
  await page.getByRole('button', { name: 'Send request' }).click();
  await expect(page.locator('#worker-results')).toContainText('PostFailed');
  await page.evaluate(() => {
    const probe = (window as Window & { __workerProbe: { records: ProbeRecord[]; dispatch(index: number, type: string): void } }).__workerProbe;
    probe.dispatch(probe.records.length - 1, 'messageerror');
  });
  await expect(page.getByText('status: failed: MessageError')).toBeVisible();
});

test('request timeout settles once without rolling back Worker work', async ({ page }) => {
  await openFrozenWorkerFixture(page);
  await page.getByRole('button', { name: 'Send held request' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records[0].posts.length).toBe(1);
  await page.clock.runFor(150);
  await expect(page.locator('#worker-results')).toContainText('Timeout');
  const result = await page.locator('#worker-results').innerText();
  expect(result.match(/Timeout/g)).toHaveLength(1);
  await expect(page.locator('#worker-settlements')).toHaveText('settlements: 1');
  await page.getByRole('button', { name: 'Send request' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records[0].received.length).toBe(1);
  await page.clock.runFor(20);
  await expect(page.locator('#worker-results')).toContainText('2|work:one');
});

test('matching progress renews only its own inactivity timeout', async ({ page }) => {
  await openFrozenWorkerFixture(page);
  await page.getByRole('button', { name: 'Send held request' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records[0].posts.length).toBe(1);
  const request = JSON.parse((await inspectWorkers(page)).records[0].posts[0]);
  await page.clock.runFor(80);
  await page.evaluate(({ id }) => {
    const probe = (window as Window & { __workerProbe: { dispatch(index: number, type: string, data?: unknown): void } }).__workerProbe;
    probe.dispatch(0, 'message', JSON.stringify({ rabbita_worker: 1, id, kind: 'progress' }));
  }, { id: request.id });
  await page.clock.runFor(80);
  await expect(page.locator('#worker-results')).not.toContainText('Timeout');
  // Cross the renewed deadline at 180ms and Rabbita's next animation frame.
  await page.clock.runFor(40);
  await expect(page.locator('#worker-results')).toContainText('Timeout');
});

test('unrelated progress does not renew another request timeout', async ({ page }) => {
  await openFrozenWorkerFixture(page);
  await page.getByRole('button', { name: 'Send held request' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records[0].posts.length).toBe(1);
  await page.clock.runFor(80);
  await page.evaluate(() => {
    const probe = (window as Window & { __workerProbe: { dispatch(index: number, type: string, data?: unknown): void } }).__workerProbe;
    probe.dispatch(0, 'message', JSON.stringify({ rabbita_worker: 1, id: 'unrelated-id', kind: 'progress' }));
  });
  await page.clock.runFor(40);
  await expect(page.locator('#worker-results')).toContainText('Timeout');
});

test('subscription removal cancels pending work and releases Worker listeners', async ({ page }) => {
  await openFrozenWorkerFixture(page);
  const baseline = await inspectWorkers(page);
  await page.getByRole('button', { name: 'Send held request' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records[0].posts.length).toBe(1);
  await expect.poll(async () => (await inspectWorkers(page)).timerCount).toBeGreaterThan(baseline.timerCount);
  await page.getByRole('button', { name: 'Toggle Worker owner' }).click();
  await page.clock.runFor(20);
  await expect(page.getByText('status: owner disabled')).toBeVisible();
  await expect.poll(async () => (await inspectWorkers(page)).active).toBe(0);
  await expect.poll(async () => (await inspectWorkers(page)).timerCount).toBe(baseline.timerCount);
  const state = await inspectWorkers(page);
  expect(state.listenerCount).toBe(0);
  await page.clock.runFor(150);
  await expect(page.locator('#worker-results')).not.toContainText('work:hold');
  await expect(page.locator('#worker-results')).toContainText('ConnectionClosed');
  await expect(page.locator('#worker-settlements')).toHaveText('settlements: 1');
});

test('unmounting the owning component disposes its pending Worker scope', async ({ page }) => {
  await openFrozenWorkerFixture(page);
  const baseline = await inspectWorkers(page);
  await page.getByRole('button', { name: 'Send held request' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records[0].posts.length).toBe(1);
  await expect.poll(async () => (await inspectWorkers(page)).timerCount).toBeGreaterThan(baseline.timerCount);
  await page.getByRole('button', { name: 'Unmount Worker panel' }).click();
  await page.clock.runFor(20);
  await expect(page.getByText('Worker panel is unmounted')).toBeVisible();
  await expect.poll(async () => (await inspectWorkers(page)).active).toBe(0);
  await expect.poll(async () => (await inspectWorkers(page)).timerCount).toBe(baseline.timerCount);
  const state = await inspectWorkers(page);
  expect(state.listenerCount).toBe(0);
  await page.clock.runFor(150);
  await expect(page.getByText('Worker panel is unmounted')).toBeVisible();
});

test('fatal message failure settles every pending waiter once and releases resources', async ({ page }) => {
  await openFrozenWorkerFixture(page);
  const baseline = await inspectWorkers(page);
  await page.getByRole('button', { name: 'Send held request' }).click();
  await page.getByRole('button', { name: 'Send held request' }).click();
  await expect.poll(async () => (await inspectWorkers(page)).records[0].posts.length).toBe(2);
  await page.evaluate(() => {
    const probe = (window as Window & { __workerProbe: { dispatch(index: number, type: string): void } }).__workerProbe;
    probe.dispatch(0, 'messageerror');
  });
  await page.clock.runFor(20);
  await expect(page.locator('#worker-status')).toContainText('MessageError');
  await expect(page.locator('#worker-settlements')).toHaveText('settlements: 2');
  const state = await inspectWorkers(page);
  expect(state.active).toBe(0);
  expect(state.listenerCount).toBe(0);
  expect(state.timerCount).toBe(baseline.timerCount);
  await page.clock.runFor(150);
  await expect(page.locator('#worker-settlements')).toHaveText('settlements: 2');
});
