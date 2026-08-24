import { expect, test } from '@playwright/test';

test('resizable handle exposes a native range with the initial size', async ({ page }) => {
  await page.goto('/');

  const handle = page.locator('#fixture-resizable-handle');
  const separator = page.locator('[data-slot="resizable-handle"][data-between="0"]');
  const group = page.locator('#fixture-resizable');

  await expect(handle).toHaveValue('50');
  await expect(separator).toHaveAttribute('aria-valuenow', '50');
  await expect(group).toHaveAttribute('data-sizes', '50,50');
});

test('resizable keyboard moves the panel boundary and clamps at the bounds', async ({ page }) => {
  await page.goto('/');

  const handle = page.locator('#fixture-resizable-handle');
  const separator = page.locator('[data-slot="resizable-handle"][data-between="0"]');
  const group = page.locator('#fixture-resizable');

  await handle.focus();
  await page.keyboard.press('ArrowUp');
  await expect(handle).toHaveValue('49');
  await expect(separator).toHaveAttribute('aria-valuenow', '49');
  await expect(group).toHaveAttribute('data-sizes', '49,51');

  await page.keyboard.press('Home');
  await expect(handle).toHaveValue('25');
  await expect(group).toHaveAttribute('data-sizes', '25,75');

  await page.keyboard.press('End');
  await expect(handle).toHaveValue('75');
  await expect(group).toHaveAttribute('data-sizes', '75,25');
});
