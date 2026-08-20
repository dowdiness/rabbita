import { expect, test } from '@playwright/test';

test('counter increments and decrements', async ({ page }) => {
  await page.goto('/');

  const count = page.getByRole('heading', { level: 1 });
  const increment = page.getByRole('button', { name: '+', exact: true });
  const decrement = page.getByRole('button', { name: '-', exact: true });

  await expect(count).toHaveText('0');

  await increment.click();
  await expect(count).toHaveText('1');

  await decrement.click();
  await expect(count).toHaveText('0');
});
