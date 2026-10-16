import { expect, test } from '@playwright/test';

test('host builds once and focus policy reads current application state', async ({ page }) => {
  await page.goto('/');
  const builds = page.getByText('Host builds: 1', { exact: true });
  await expect(builds).toBeVisible();
  await page.getByRole('button', { name: 'Use alternate editor' }).click();
  for (let i = 0; i < 2; i++) {
    await page.getByRole('button', { name: 'Show toast', exact: true }).click();
    const close = page.getByRole('button', { name: 'Close notification' }).last();
    await close.focus();
    await close.press('Enter');
    await expect(page.getByRole('textbox', { name: 'Alternate editor' })).toBeFocused();
    await expect(page.getByRole('status')).toHaveCount(0);
    await expect(builds).toBeVisible();
  }
});

for (const ownership of ['focus', 'hover'] as const) {
  test(`replacement retains stationary ${ownership} pause in its DOM slot`, async ({ page }) => {
    await page.clock.install();
    await page.goto('/');
    const show = page.getByRole('button', { name: 'Show toast', exact: true });
    for (let i = 0; i < 3; i++) await show.click();
    const toast = page.getByRole('status').first();
    const close = toast.getByRole('button', { name: 'Close notification' });
    if (ownership === 'focus') await close.focus();
    else await toast.hover();
    // Programmatic activation leaves the pointer and keyboard focus stationary.
    await show.evaluate(button => (button as HTMLButtonElement).click());
    await page.clock.runFor(6000);
    await expect(toast).toBeVisible();
    if (ownership === 'focus') {
      await expect(close).toBeFocused();
      await page.getByRole('textbox', { name: 'Editor', exact: true }).focus();
    } else {
      await page.mouse.move(0, 0);
    }
    await page.clock.runFor(500);
    await expect(page.getByRole('status')).toHaveCount(0);
  });
}

test('keyboard close uses the provided focus policy, expiry does not', async ({ page }) => {
  await page.clock.install();
  await page.goto('/');
  const show = page.getByRole('button', { name: 'Show toast', exact: true });
  await show.click();
  const close = page.getByRole('button', { name: 'Close notification' });
  await close.focus();
  await close.press('Enter');
  const editor = page.getByRole('textbox', { name: 'Editor', exact: true });
  await expect(editor).toBeFocused();
  await page.clock.runFor(500);
  await show.click();
  await editor.focus();
  await page.clock.runFor(5000);
  await expect(page.getByRole('status')).toHaveCount(0);
  await expect(editor).toBeFocused();
  // An unfocused expiry must not call a policy that would focus the editor.
  await show.click();
  await page.clock.runFor(5000);
  await expect(show).toBeFocused();
});

test('two Sonner hosts both receive document pause without sharing local pause', async ({ page }) => {
  await page.clock.install();
  await page.goto('/');
  await page.getByRole('button', { name: 'Show toast', exact: true }).click();
  await page.getByRole('button', { name: 'Show other host' }).click();
  await page.evaluate(() => window.dispatchEvent(new Event('blur')));
  await page.clock.runFor(5000);
  await expect(page.getByRole('status')).toHaveCount(2);
  await page.evaluate(() => window.dispatchEvent(new Event('focus')));
  await page.clock.runFor(500);
  await expect(page.getByRole('status')).toHaveCount(0);
  await page.getByRole('button', { name: 'Show toast', exact: true }).click();
  await page.getByRole('button', { name: 'Show other host' }).click();
  const primary = page.locator('[data-slot="sonner"][data-position="bottom-right"]');
  await primary.getByRole('button', { name: 'Close notification' }).focus();
  await page.clock.runFor(5000);
  await expect(primary.getByRole('status')).toBeVisible();
  await expect(page.getByText('Other host', { exact: true })).toBeHidden();
});

test('toast shows with its title and description and closes from its button', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Show toast' }).click();
  const toast = page.getByRole('status');
  await expect(toast).toBeVisible();
  await expect(toast.getByText('Saved')).toBeVisible();
  await expect(toast.getByText('The draft is kept.')).toBeVisible();

  await toast.getByRole('button', { name: 'Close notification' }).click();
  await expect(toast).toBeHidden();
});

test('toast dismisses itself after its duration', async ({ page }) => {
  await page.clock.install();
  await page.goto('/');

  await page.getByRole('button', { name: 'Show toast' }).click();
  const toast = page.getByRole('status');
  await expect(toast).toBeVisible();

  await page.clock.runFor(5000);
  await expect(toast).toBeHidden();
});

test('toast swipe dismisses toward the inline end', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Show toast' }).click();
  const toast = page.getByRole('status');
  await expect(toast).toBeVisible();

  const box = await toast.boundingBox();
  expect(box).not.toBeNull();
  const startX = box!.x + 24;
  const startY = box!.y + box!.height / 2;
  await page.mouse.move(startX, startY);
  await page.mouse.down();
  await page.mouse.move(startX + 200, startY, { steps: 6 });
  await page.mouse.up();
  await expect(toast).toBeHidden();
});

test('toast pauses its timeout while hovered and resumes after leaving', async ({ page }) => {
  await page.clock.install();
  await page.goto('/');

  await page.getByRole('button', { name: 'Show toast' }).click();
  const toast = page.getByRole('status');
  await expect(toast).toBeVisible();
  await toast.hover();
  await page.clock.runFor(5000);
  await expect(toast).toBeVisible();

  await page.getByRole('heading', { name: 'Toast', exact: true }).hover();
  await page.clock.runFor(4500);
  await expect(toast).toBeHidden();
});

test('sonner bounds its queue and dismisses every visible toast', async ({ page }) => {
  await page.goto('/');

  const show = page.getByRole('button', { name: 'Show toast' });
  await show.click();
  await show.click();
  await show.click();
  await show.click();
  await expect(page.getByRole('status')).toHaveCount(3);
  const slots = await page.locator('[data-slot="toast"]').elementHandles();

  await page.getByRole('button', { name: 'Dismiss all toasts' }).click();
  await expect(page.getByRole('status')).toHaveCount(0);
  await expect(page.getByRole('button', { name: 'Close notification' })).toHaveCount(0);
  for (const slot of slots) {
    expect(await slot.evaluate(element => element.isConnected)).toBe(true);
    await slot.evaluate(element => (element.querySelector('button') as HTMLButtonElement).focus());
    expect(await slot.evaluate(element => element.contains(document.activeElement))).toBe(false);
  }
  await show.click();
  await expect(page.getByRole('status')).toHaveCount(1);
  expect(await slots[0].evaluate(element => element === document.querySelector('[data-slot="toast"]'))).toBe(true);
});
