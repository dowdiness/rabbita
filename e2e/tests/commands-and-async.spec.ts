import { expect, test } from '@playwright/test';

test('async initialization and perform converge to their results', async ({ page }) => {
  await page.goto('/');

  await expect(page.locator('#init-command')).toHaveText('init: ready');
  await page.getByRole('button', { name: 'Run perform' }).click();
  await expect(page.locator('#perform-status')).toHaveText('perform: performed');
});

test('attempt converts an async rejection into a message', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Run failing attempt' }).click();
  await expect(page.locator('#attempt-status')).toHaveText('attempt: failed');
});

test('delay follows the controllable browser clock', async ({ page }) => {
  const start = new Date('2026-01-01T00:00:00Z');
  await page.clock.install({ time: start });
  await page.goto('/');

  await page.getByRole('button', { name: 'Run delayed command' }).click();
  await expect(page.locator('#delay-status')).toHaveText('delay: waiting');
  await page.clock.pauseAt(await page.evaluate(() => Date.now()));
  await page.clock.runFor(1000);
  await expect(page.locator('#delay-status')).toHaveText('delay: finished');
});

test('batch eventually applies every message without asserting order', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Run batch' }).click();
  await expect(page.locator('#batch-status')).toHaveText('batch: complete');
});
