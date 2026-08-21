import { expect, test } from '@playwright/test';

test('deep links, push, and replace preserve application state', async ({ page }) => {
  await page.goto('/deep?mode=e2e');

  await expect(page.locator('#location')).toHaveText('/deep?mode=e2e');
  await page.getByRole('button', { name: 'Increment preserved state' }).click();
  await expect(page.locator('#preserved-count')).toHaveText('count: 1');

  await page.getByRole('button', { name: 'Push first URL' }).click();
  await expect(page).toHaveURL(/\/first\?from=push$/);
  await expect(page.locator('#location')).toHaveText('/first?from=push');
  await expect(page.locator('#preserved-count')).toHaveText('count: 1');

  await page.getByRole('button', { name: 'Replace with second URL' }).click();
  await expect(page).toHaveURL(/\/second\?from=replace$/);
  await expect(page.locator('#location')).toHaveText('/second?from=replace');
  await expect(page.locator('#preserved-count')).toHaveText('count: 1');
});

test('back and forward traverse same-origin history without reloads', async ({ page }) => {
  await page.goto('/origin');
  await page.getByRole('button', { name: 'Increment preserved state' }).click();
  await page.getByRole('button', { name: 'Push first URL' }).click();
  await page.getByRole('button', { name: 'Replace with second URL' }).click();

  await page.getByRole('button', { name: 'Go back' }).click();
  await expect(page).toHaveURL(/\/origin$/);
  await expect(page.locator('#location')).toHaveText('/origin');
  await expect(page.locator('#preserved-count')).toHaveText('count: 1');

  await page.getByRole('button', { name: 'Go forward' }).click();
  await expect(page).toHaveURL(/\/second\?from=replace$/);
  await expect(page.locator('#location')).toHaveText('/second?from=replace');
  await expect(page.locator('#preserved-count')).toHaveText('count: 1');
});
