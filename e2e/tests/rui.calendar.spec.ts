import { expect, test } from '@playwright/test';

const calendarSection = '#fixture-section-calendar';

test('calendar marks today and the selected day', async ({ page }) => {
  await page.goto('/');

  const section = page.locator(calendarSection);
  const grid = section.getByRole('grid');
  await expect(grid).toBeVisible();

  const today = section.locator('[data-slot="calendar-day-button"][data-day="2026-07-16"]');
  await expect(today).toHaveAttribute('aria-selected', 'true');
  await expect(today).toHaveAttribute('aria-current', 'date');
});

test('calendar selection moves with clicks and focus moves with arrows', async ({ page }) => {
  await page.goto('/');

  const section = page.locator(calendarSection);
  const day16 = section.locator('[data-slot="calendar-day-button"][data-day="2026-07-16"]');
  const day21 = section.locator('[data-slot="calendar-day-button"][data-day="2026-07-21"]');
  const day22 = section.locator('[data-slot="calendar-day-button"][data-day="2026-07-22"]');

  await day21.click();
  await expect(day21).toHaveAttribute('aria-selected', 'true');
  await expect(day16).toHaveAttribute('aria-selected', 'false');
  await expect(day21).toHaveAttribute('data-focused', '');

  await page.keyboard.press('ArrowRight');
  await expect(day22).toHaveAttribute('data-focused', '');
  await expect(day22).toHaveAttribute('aria-selected', 'false');
});

test('date picker opens a popup calendar and commits a chosen day', async ({ page }) => {
  await page.goto('/');

  const trigger = page.locator('#fixture-date-picker-trigger');
  await expect(trigger).toHaveText('July 16, 2026');
  await expect(trigger).toHaveAttribute('aria-expanded', 'false');

  await trigger.click();
  await expect(trigger).toHaveAttribute('aria-expanded', 'true');
  const popup = page.locator('[data-slot="date-picker-content"]');
  await expect(popup).toBeVisible();
  await expect(popup.getByRole('grid')).toBeVisible();

  await popup.locator('[data-slot="calendar-day-button"][data-day="2026-07-21"]').click();
  await expect(trigger).toHaveText('July 21, 2026');
  await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  await expect(popup).toBeHidden();
});

test('date picker closes on Escape without changing the value', async ({ page }) => {
  await page.goto('/');

  const trigger = page.locator('#fixture-date-picker-trigger');
  await trigger.click();
  await expect(page.locator('[data-slot="date-picker-content"]')).toBeVisible();

  await page.keyboard.press('Escape');
  await expect(page.locator('[data-slot="date-picker-content"]')).toBeHidden();
  await expect(trigger).toHaveText('July 16, 2026');
});
