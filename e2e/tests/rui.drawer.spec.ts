import { expect, test } from '@playwright/test';

test('drawer opens, traps modal semantics, and closes on Escape', async ({ page }) => {
  await page.goto('/');

  const trigger = page.getByRole('button', { name: 'Open drawer' });
  const dialog = page.getByRole('dialog', { name: 'Drawer title' });

  await expect(dialog).toBeHidden();
  await expect(trigger).toHaveAttribute('aria-expanded', 'false');

  await trigger.click();
  await expect(dialog).toBeVisible();
  await expect(dialog).toHaveAttribute('aria-modal', 'true');
  await expect(trigger).toHaveAttribute('aria-expanded', 'true');
  await expect(page.getByText('Drawer body')).toBeVisible();

  await page.keyboard.press('Escape');
  await expect(dialog).toBeHidden();
  await expect(trigger).toHaveAttribute('aria-expanded', 'false');
});

test('drawer closes from the footer button and from the overlay', async ({ page }) => {
  await page.goto('/');

  const trigger = page.getByRole('button', { name: 'Open drawer' });
  const dialog = page.getByRole('dialog', { name: 'Drawer title' });

  await trigger.click();
  await expect(dialog).toBeVisible();
  await dialog.getByRole('button', { name: 'Close drawer' }).last().click();
  await expect(dialog).toBeHidden();

  await trigger.click();
  await expect(dialog).toBeVisible();
  await page.mouse.click(5, 5);
  await expect(dialog).toBeHidden();
});
