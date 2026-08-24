import { expect, test } from '@playwright/test';

const sidebarRoot = '#fixture-sidebar-root';

test('sidebar collapses and expands through the trigger', async ({ page }) => {
  await page.goto('/');

  const root = page.locator(sidebarRoot);
  const trigger = page.getByRole('button', { name: 'Toggle sidebar' });

  await expect(root).toHaveAttribute('data-state', 'expanded');
  await trigger.click();
  await expect(root).toHaveAttribute('data-state', 'collapsed');
  await trigger.click();
  await expect(root).toHaveAttribute('data-state', 'expanded');
});

test('collapsed icon sidebar opens a tooltip on hover', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Toggle sidebar' }).click();
  await expect(page.locator(sidebarRoot)).toHaveAttribute('data-state', 'collapsed');

  const overview = page.locator('#fixture-sidebar-overview');
  await expect(overview).toBeVisible();

  const tooltip = page.getByRole('tooltip', { name: 'Overview' });
  await expect(tooltip).toBeHidden();
  await overview.hover();
  await expect(tooltip).toBeVisible();

  await page.getByText('Workspace overview', { exact: true }).hover();
  await expect(tooltip).toBeHidden();
});

test('sidebar rail drag resizes without collapsing', async ({ page }) => {
  await page.goto('/');

  const root = page.locator(sidebarRoot);
  const rail = page.getByRole('button', { name: 'Resize sidebar' });
  const before = await root.boundingBox();
  const railBox = await rail.boundingBox();
  expect(before).not.toBeNull();
  expect(railBox).not.toBeNull();

  const startX = railBox!.x + railBox!.width / 2;
  const startY = railBox!.y + railBox!.height / 2;
  await page.mouse.move(startX, startY);
  await page.mouse.down();
  await page.mouse.move(startX + 40, startY, { steps: 4 });
  await page.mouse.up();

  const after = await root.boundingBox();
  expect(after!.width).toBeGreaterThan(before!.width);
  await expect(root).toHaveAttribute('data-state', 'expanded');
});
