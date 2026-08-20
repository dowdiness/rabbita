import { defineConfig, devices } from '@playwright/test';

const isCI = Boolean(process.env.CI);
const apps = [
  { name: 'counter', port: 4300 },
  { name: 'toggle', port: 4301 },
] as const;
const appUrl = (port: number) => `http://127.0.0.1:${port}`;

export default defineConfig({
  testDir: './tests',
  outputDir: './test-results',
  fullyParallel: true,
  forbidOnly: isCI,
  retries: isCI ? 1 : 0,
  workers: isCI ? 1 : undefined,
  reporter: [
    ['list'],
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
  ],
  use: {
    screenshot: 'only-on-failure',
    trace: 'on-first-retry',
  },
  projects: apps.map(({ name, port }) => ({
    name: `${name}-chromium`,
    testMatch: `**/${name}.spec.ts`,
    use: {
      ...devices['Desktop Chrome'],
      baseURL: appUrl(port),
    },
  })),
  webServer: apps.map(({ name, port }) => ({
    command: `warren -C ./apps/${name} dev --browser-entry . --direct --port ${port}`,
    url: appUrl(port),
    reuseExistingServer: !isCI,
    timeout: 120_000,
    stdout: 'pipe' as const,
  })),
});
