import { expect, test } from '@playwright/test';

test('unmount removes its DOM, unloads subscriptions once, and is idempotent', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Mount A' }).click();
  await expect(page.locator('#child-status')).toHaveText('A ready');

  await page.getByRole('button', { name: 'Unmount current' }).click();
  await expect(page.locator('#mount-target')).toBeEmpty();
  await expect(page.locator('#unload-count')).toHaveText('unloads: 1');

  await page.getByRole('button', { name: 'Unmount current' }).click();
  await expect(page.locator('#mount-target')).toBeEmpty();
  await expect(page.locator('#unload-count')).toHaveText('unloads: 1');
});

test('stale delayed work cannot affect a replacement mounted in the same container', async ({ page }) => {
  await page.clock.install({ time: new Date('2026-01-01T00:00:00Z') });
  await page.goto('/');

  await page.getByRole('button', { name: 'Mount A' }).click();
  await page.getByRole('button', { name: 'Schedule delayed A update' }).click();
  await expect(page.locator('#child-status')).toHaveText('A waiting');

  await page.getByRole('button', { name: 'Unmount current' }).click();
  await page.getByRole('button', { name: 'Mount B' }).click();
  await expect(page.locator('#child-status')).toHaveText('B mounted');

  await page.clock.runFor(1000);
  await expect(page.locator('#child-status')).toHaveText('B mounted');
  await expect(page.locator('#unload-count')).toHaveText('unloads: 1');
  await expect(page.locator('#delayed-delivery-count')).toHaveText('delayed deliveries: 0');
});

test('a stale handle cleans its runtime without removing a replacement root', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Mount A' }).click();
  await expect(page.locator('#child-status')).toHaveText('A ready');
  await page.getByRole('button', { name: 'Replace A with B' }).click();
  await expect(page.locator('#child-status')).toHaveText('B mounted');

  await page.getByRole('button', { name: 'Unmount stale A' }).click();
  await expect(page.locator('#shell-status')).toHaveText('stale A unmount completed');
  await expect(page.locator('#child-status')).toHaveText('B mounted');
  await expect(page.locator('#unload-count')).toHaveText('unloads: 1');
});

test('queued frame work cannot publish after unmount', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Mount A' }).click();
  await expect(page.locator('#child-status')).toHaveText('A ready');
  await page.getByRole('button', { name: 'Queue A frame then unmount' }).click();
  await expect(page.locator('#shell-status')).toHaveText('queued frame unmounted');
  await expect(page.locator('#mount-target')).toBeEmpty();

  await page.getByRole('button', { name: 'Mount B' }).click();
  await expect(page.locator('#child-status')).toHaveText('B mounted');
  await page.evaluate(() => new Promise<void>((resolve) => {
    requestAnimationFrame(() => requestAnimationFrame(() => resolve()));
  }));
  await expect(page.locator('#child-status')).toHaveText('B mounted');
  await expect(page.locator('#unload-count')).toHaveText('unloads: 1');
  await expect(page.locator('#frame-delivery-count')).toHaveText('frame deliveries: 0');
});
