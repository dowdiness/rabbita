import { expect, test } from '@playwright/test';

test('toggle switches between off and on', async ({ page }) => {
  await page.goto('/');

  const state = page.getByRole('heading', { level: 1 });
  const toggle = page.getByRole('button', { name: 'Toggle', exact: true });

  await expect(state).toHaveText('Off');

  await toggle.click();
  await expect(state).toHaveText('On');

  await toggle.click();
  await expect(state).toHaveText('Off');
});
