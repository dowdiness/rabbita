import { expect, test } from '@playwright/test';

test('context menu opens on right click and activates a normal item', async ({ page }) => {
  await page.goto('/menus');

  const target = page.locator('[data-slot="context-menu-trigger"]');
  const menu = page.getByRole('menu', { name: 'Fixture canvas menu' });

  await expect(target).toContainText('Right-click fixture canvas');
  await target.click({ button: 'right' });
  await expect(menu).toBeVisible();
  await expect(menu.getByRole('menuitem', { name: 'Unavailable action' })).toHaveAttribute(
    'aria-disabled',
    'true',
  );
  await menu.getByRole('menuitem', { name: 'Duplicate fixture' }).click();
  await expect(menu).toBeHidden();
  await expect(page.locator('#fixture-context-menu-output')).toHaveText('duplicated');
});

test('context menu checkbox and radio items retain owned state', async ({ page }) => {
  await page.goto('/menus');

  const target = page.locator('[data-slot="context-menu-trigger"]');
  const menu = page.getByRole('menu', { name: 'Fixture canvas menu' });

  await target.focus();
  await target.click({ button: 'right' });
  const checkbox = menu.getByRole('menuitemcheckbox', { name: 'Show grid' });
  await expect(checkbox).toHaveAttribute('aria-checked', 'true');
  await checkbox.click();
  await expect(menu).toBeVisible();
  await expect(checkbox).toHaveAttribute('aria-checked', 'false');

  const canvas = menu.getByRole('menuitemradio', { name: 'Canvas layout' });
  const editor = menu.getByRole('menuitemradio', { name: 'Editor layout' });
  await expect(canvas).toHaveAttribute('aria-checked', 'true');
  await editor.click();
  await expect(menu).toBeVisible();
  await expect(canvas).toHaveAttribute('aria-checked', 'false');
  await expect(editor).toHaveAttribute('aria-checked', 'true');

  await page.keyboard.press('Escape');
  await expect(menu).toBeHidden();
  await expect(target).toBeFocused();
});

test('context menu keyboard navigation skips disabled items and opens submenu', async ({ page }) => {
  await page.goto('/menus');

  const target = page.locator('[data-slot="context-menu-trigger"]');
  await target.focus();
  await page.keyboard.press('Shift+F10');

  const menu = page.getByRole('menu', { name: 'Fixture canvas menu' });
  const duplicate = menu.getByRole('menuitem', { name: 'Duplicate fixture' });
  const checkbox = menu.getByRole('menuitemcheckbox', { name: 'Show grid' });
  await expect(menu).toBeVisible();
  await expect(duplicate).toBeFocused();

  await page.keyboard.press('ArrowDown');
  await expect(checkbox).toBeFocused();

  const submenuTrigger = menu.getByRole('menuitem', { name: 'Move fixture' });
  await submenuTrigger.hover();
  await expect(page.getByRole('menuitem', { name: 'Design system' })).toBeVisible();
  await submenuTrigger.focus();
  await page.keyboard.press('ArrowRight');
  await expect(page.getByRole('menuitem', { name: 'Design system' })).toBeFocused();
});
