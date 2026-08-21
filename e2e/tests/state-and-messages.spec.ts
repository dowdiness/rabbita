import { expect, test } from '@playwright/test';

test('pure and command-capable state update derived values', async ({ page }) => {
  await page.goto('/');

  await expect(page.locator('#init-status')).toHaveText('init: ready');
  await expect(page.locator('#pure-count')).toHaveText('pure: 0');
  await expect(page.locator('#doubled')).toHaveText('doubled: 0');

  await page.getByRole('button', { name: 'Increment pure' }).click();
  await expect(page.locator('#pure-count')).toHaveText('pure: 1');
  await expect(page.locator('#doubled')).toHaveText('doubled: 2');
  await expect(page.locator('#total')).toHaveText('total: 1');

  await page.getByRole('button', { name: 'Increment stateful' }).click();
  await expect(page.locator('#stateful-count')).toHaveText('stateful: 1');
});

test('state with input reads the latest variable value', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Add current step' }).click();
  await expect(page.locator('#input-count')).toHaveText('input count: 1');

  await page.getByRole('button', { name: 'Set step to 3' }).click();
  await expect(page.locator('#step')).toHaveText('step: 3');
  await page.getByRole('button', { name: 'Add current step' }).click();
  await expect(page.locator('#input-count')).toHaveText('input count: 4');
  await expect(page.locator('#total')).toHaveText('total: 4');
});

test('mapped emitters forward input payloads', async ({ page }) => {
  await page.goto('/');

  await page.getByPlaceholder('Mapped input').fill('rabbit');
  await expect(page.locator('#mapped-value')).toHaveText('mapped: rabbit');
});
