import { expect, test } from '@playwright/test';

test('keyed rows preserve branch state until removal', async ({ page }) => {
  await page.goto('/');

  const firstInput = page.locator('#row-input-1');
  await firstInput.fill('unfinished draft');
  await page.getByRole('button', { name: 'Increment one' }).click();
  await expect(page.locator('#row-count-1')).toHaveText('local: 1');
  await page.getByRole('button', { name: 'Reorder rows' }).click();
  await expect
    .poll(() => page.locator('#rows > li').evaluateAll((rows) => rows.map(({ id }) => id)))
    .toEqual(['row-2', 'row-1']);
  await expect(firstInput).toHaveValue('unfinished draft');
  await expect(page.locator('#row-count-1')).toHaveText('local: 1');

  await page.getByRole('button', { name: 'Remove first row' }).click();
  await expect(page.locator('#row-1')).toHaveCount(0);
  await page.getByRole('button', { name: 'Add first row' }).click();
  await expect(page.locator('#row-count-1')).toHaveText('local: 0');
  await expect(page.locator('#row-input-1')).toHaveValue('');
});

test('enumerated branches retain cached state', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Increment cached branch' }).click();
  await expect(page.locator('#cached-branch')).toContainText('A cached count: 1');
  await page.getByRole('button', { name: 'Show cached B' }).click();
  await expect(page.locator('#cached-branch')).toContainText('B cached count: 0');
  await page.getByRole('button', { name: 'Show cached A' }).click();
  await expect(page.locator('#cached-branch')).toContainText('A cached count: 1');
});

test('switched branches are recreated after disposal', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Increment switched branch' }).click();
  await expect(page.locator('#switched-branch')).toContainText('A switched count: 1');
  await page.getByRole('button', { name: 'Show switched B' }).click();
  await expect(page.locator('#switched-branch')).toContainText('B switched count: 0');
  await page.getByRole('button', { name: 'Show switched A' }).click();
  await expect(page.locator('#switched-branch')).toContainText('A switched count: 0');
});
