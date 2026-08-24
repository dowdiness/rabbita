import { expect, test } from '@playwright/test';

test('carousel exposes slides and the active one is marked', async ({ page }) => {
  await page.goto('/');

  const first = page.getByRole('group', { name: 'Slide 1 of 3' });
  const second = page.getByRole('group', { name: 'Slide 2 of 3', includeHidden: true });
  const third = page.getByRole('group', { name: 'Slide 3 of 3', includeHidden: true });

  await expect(first).toHaveAttribute('aria-current', 'true');
  await expect(second).not.toHaveAttribute('aria-current', 'true');
  await expect(third).not.toHaveAttribute('aria-current', 'true');
});

test('carousel next and previous buttons step through slides', async ({ page }) => {
  await page.goto('/');

  const next = page.getByRole('button', { name: 'Next slide' });
  const previous = page.getByRole('button', { name: 'Previous slide' });
  const first = page.getByRole('group', { name: 'Slide 1 of 3' });
  const second = page.getByRole('group', { name: 'Slide 2 of 3' });
  const third = page.getByRole('group', { name: 'Slide 3 of 3' });

  await next.click();
  await expect(second).toHaveAttribute('aria-current', 'true');

  await next.click();
  await expect(third).toHaveAttribute('aria-current', 'true');

  await previous.click();
  await expect(second).toHaveAttribute('aria-current', 'true');
});

test('carousel loop wraps in both directions', async ({ page }) => {
  await page.goto('/');

  const next = page.getByRole('button', { name: 'Next slide' });
  const previous = page.getByRole('button', { name: 'Previous slide' });
  const first = page.getByRole('group', { name: 'Slide 1 of 3' });
  const third = page.getByRole('group', { name: 'Slide 3 of 3' });

  await next.click();
  await next.click();
  await expect(third).toHaveAttribute('aria-current', 'true');
  await next.click();
  await expect(first).toHaveAttribute('aria-current', 'true');

  await previous.click();
  await expect(third).toHaveAttribute('aria-current', 'true');
});
