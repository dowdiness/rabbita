import { expect, test } from '@playwright/test';

test('input, change, select, and submit events update state', async ({ page }) => {
  await page.goto('/');

  const name = page.getByLabel('Name');
  await name.fill('rabbit');
  await expect(page.locator('#input-value')).toHaveText('input: rabbit');

  await name.press('Tab');
  await expect(page.locator('#change-value')).toHaveText('change: rabbit');

  await page.getByLabel('Color').selectOption('blue');
  await expect(page.locator('#choice-value')).toHaveText('choice: blue');

  await page.getByRole('button', { name: 'Submit form' }).click();
  await expect(page.locator('#submit-count')).toHaveText('submits: 1');
  await expect(page).toHaveURL('/');
});

test('file input emits typed metadata and allows the same file again', async ({ page }) => {
  await page.goto('/');

  const file = {
    name: 'notes.md',
    mimeType: 'text/markdown',
    buffer: Buffer.from('hello'),
  };
  const secondFile = {
    name: 'other.txt',
    mimeType: 'text/plain',
    buffer: Buffer.from('other'),
  };
  const input = page.getByLabel('Choose files');

  await input.setInputFiles([file, secondFile]);
  await expect(page.locator('#file-name')).toHaveText('file name: notes.md');
  await expect(page.locator('#file-type')).toHaveText('file type: text/markdown');
  await expect(page.locator('#file-size')).toHaveText('file size: 5');
  await expect(page.locator('#file-count')).toHaveText('file count: 2');
  await expect(page.locator('#file-modified')).toHaveText('file modified: true');
  await expect(page.locator('#file-selections')).toHaveText('file selections: 1');
  await expect(page.locator('#file-bytes')).toHaveText('file bytes: 5, first: 104, last: 111');
  await expect(input).toHaveValue('');

  await input.setInputFiles([file, secondFile]);
  await expect(page.locator('#file-selections')).toHaveText('file selections: 2');
  await expect(input).toHaveValue('');
});

test('file input cancellation emits no selection', async ({ page }) => {
  await page.goto('/');

  const input = page.getByLabel('Choose files');
  await input.dispatchEvent('cancel');

  await expect(page.locator('#file-selections')).toHaveText('file selections: 0');
  await expect(input).toHaveValue('');
});

test('file byte read failure returns through the managed command path', async ({ page }) => {
  await page.addInitScript(() => {
    Blob.prototype.arrayBuffer = () => Promise.reject(new Error('read failed'));
  });
  await page.goto('/');

  await page.getByLabel('Choose files').setInputFiles({
    name: 'unreadable.md',
    mimeType: 'text/markdown',
    buffer: Buffer.from('content'),
  });

  await expect(page.locator('#file-read')).toHaveText('file read: failed');
});

test('attributes and DOM properties are added, updated, and removed', async ({ page }) => {
  await page.goto('/');

  const decorated = page.getByRole('button', { name: 'Decorated target' });
  await expect(decorated).not.toHaveAttribute('title');
  await page.getByRole('button', { name: 'Toggle title attribute' }).click();
  await expect(decorated).toHaveAttribute('title', 'decorated');
  await page.getByRole('button', { name: 'Toggle title attribute' }).click();
  await expect(decorated).not.toHaveAttribute('title');

  const controlledButton = page.getByRole('button', { name: 'Controlled button' });
  await expect(controlledButton).toBeEnabled();
  await page.getByRole('button', { name: 'Toggle disabled' }).click();
  await expect(controlledButton).toBeDisabled();
  await page.getByRole('button', { name: 'Toggle disabled' }).click();
  await expect(controlledButton).toBeEnabled();

  const checkbox = page.getByLabel('Controlled checkbox');
  await expect(checkbox).not.toBeChecked();
  await page.getByRole('button', { name: 'Toggle checked' }).click();
  await expect(checkbox).toBeChecked();

  await page.getByLabel('Name').fill('temporary');
  await page.getByRole('button', { name: 'Reset controlled value' }).click();
  await expect(page.getByLabel('Name')).toHaveValue('reset');
});

test('focus, keyboard, and composed handlers all dispatch', async ({ page }) => {
  await page.goto('/');

  const name = page.getByLabel('Name');
  await name.focus();
  await expect(page.locator('#focus-state')).toHaveText('focused');
  await name.press('A');
  await expect(page.locator('#keydown-count')).toHaveText('keydowns: 1');
  await name.blur();
  await expect(page.locator('#focus-state')).toHaveText('blurred');

  await page.getByRole('button', { name: 'Run composed handlers' }).click();
  await expect(page.locator('#handler-a')).toHaveText('handler a: 1');
  await expect(page.locator('#handler-b')).toHaveText('handler b: 1');
});
