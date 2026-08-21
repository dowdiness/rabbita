import { expect, test } from '@playwright/test';

test('resize and global keyboard subscriptions deliver browser events', async ({ page }) => {
  await page.goto('/');

  await page.setViewportSize({ width: 900, height: 700 });
  await expect(page.locator('#viewport')).toHaveText('viewport: 900x700');
  await expect(page.locator('#resize-count')).toHaveText(/resizes: [1-9]\d*/);

  await page.keyboard.press('K');
  await expect(page.locator('#key-count')).toHaveText('keys: 1');
  await expect(page.locator('#last-key')).toHaveText('last key: K');
});

test('subscriptions stop when disabled and resume when enabled', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Disable subscriptions' }).click();
  await expect(page.locator('#subscription-state')).toHaveText('inactive');
  await page.evaluate(() => window.dispatchEvent(new Event('resize')));
  await page.keyboard.press('X');
  await page.getByRole('button', { name: 'Flush barrier' }).click();
  await expect(page.locator('#barrier')).toHaveText('barrier: 1');
  await expect(page.locator('#resize-count')).toHaveText('resizes: 0');
  await expect(page.locator('#key-count')).toHaveText('keys: 0');

  await page.getByRole('button', { name: 'Enable subscriptions' }).click();
  await expect(page.locator('#subscription-state')).toHaveText('active');
  await page.evaluate(() => window.dispatchEvent(new Event('resize')));
  await page.keyboard.press('Y');
  await expect(page.locator('#resize-count')).toHaveText('resizes: 1');
  await expect(page.locator('#key-count')).toHaveText('keys: 1');
  await expect(page.locator('#last-key')).toHaveText('last key: Y');
});

test('a retained subscription dispatches through the latest tagger', async ({ page }) => {
  await page.goto('/');

  await expect(page.locator('#tagger-mode')).toHaveText('tagger: old');
  await page.keyboard.press('A');
  await expect(page.locator('#old-tagger-count')).toHaveText('old tagger: 1');
  await expect(page.locator('#new-tagger-count')).toHaveText('new tagger: 0');

  await page.getByRole('button', { name: 'Use new tagger' }).click();
  await expect(page.locator('#tagger-mode')).toHaveText('tagger: new');
  await page.keyboard.press('B');
  await expect(page.locator('#old-tagger-count')).toHaveText('old tagger: 1');
  await expect(page.locator('#new-tagger-count')).toHaveText('new tagger: 1');
  await expect(page.locator('#last-key')).toHaveText('last key: B');

  await page.getByRole('button', { name: 'Use old tagger' }).click();
  await expect(page.locator('#tagger-mode')).toHaveText('tagger: old');
  await page.keyboard.press('C');
  await expect(page.locator('#old-tagger-count')).toHaveText('old tagger: 2');
  await expect(page.locator('#new-tagger-count')).toHaveText('new tagger: 1');
  await expect(page.locator('#last-key')).toHaveText('last key: C');
});
