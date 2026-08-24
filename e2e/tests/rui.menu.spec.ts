import { expect, test } from '@playwright/test';

test('dropdown menu opens, exposes items, and closes after a selection', async ({ page }) => {
  await page.goto('/');

  const trigger = page.getByRole('button', { name: 'Workspace menu' });
  const menu = page.getByRole('menu', { name: 'Workspace menu' });

  await expect(menu).toBeHidden();
  await trigger.click();
  await expect(menu).toBeVisible();
  await expect(menu.getByRole('menuitem', { name: 'New tab' })).toBeVisible();
  await expect(menu.getByRole('menuitem', { name: 'Duplicate workspace' })).toHaveAttribute(
    'aria-disabled',
    'true',
  );

  await menu.getByRole('menuitem', { name: 'Invite member' }).click();
  await expect(menu).toBeHidden();
});

test('dropdown menu closes on Escape and on outside pointer press', async ({ page }) => {
  await page.goto('/');

  const trigger = page.getByRole('button', { name: 'Workspace menu' });
  const menu = page.getByRole('menu', { name: 'Workspace menu' });

  await trigger.click();
  await expect(menu).toBeVisible();
  await page.keyboard.press('Escape');
  await expect(menu).toBeHidden();

  await trigger.click();
  await expect(menu).toBeVisible();
  await page.getByRole('heading', { level: 1 }).click();
  await expect(menu).toBeHidden();
});

test('menubar opens one menu at a time and closes on Escape', async ({ page }) => {
  await page.goto('/');

  const menubar = page.getByRole('menubar', { name: 'Fixture application menu' });
  await expect(menubar).toBeVisible();

  const file = menubar.getByRole('menuitem', { name: 'File' });
  const help = menubar.getByRole('menuitem', { name: 'Help' });
  const fileMenu = page.getByRole('menu', { name: 'File' });
  const helpMenu = page.getByRole('menu', { name: 'Help' });

  await file.click();
  await expect(fileMenu).toBeVisible();
  await expect(fileMenu.getByRole('menuitem', { name: 'New project' })).toBeVisible();
  await expect(fileMenu.getByRole('menuitem', { name: 'Import' })).toHaveAttribute(
    'aria-disabled',
    'true',
  );
  await expect(helpMenu).toBeHidden();

  await help.click();
  await expect(helpMenu).toBeVisible();
  await expect(helpMenu.getByRole('menuitem', { name: 'Keyboard shortcuts' })).toBeVisible();
  await expect(fileMenu).toBeHidden();

  await page.keyboard.press('Escape');
  await expect(helpMenu).toBeHidden();
});
