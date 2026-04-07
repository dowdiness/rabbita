import { spawnSync } from 'node:child_process';

const result = spawnSync(
  'node',
  ['../../../website/node_modules/vite/bin/vite.js', 'build'],
  { cwd: process.cwd(), encoding: 'utf8' },
);

const output = `${result.stdout ?? ''}${result.stderr ?? ''}`;
if (result.status === 0) {
  throw new Error('Expected vite build to fail without local moon.mod.json');
}

if (!output.includes('Cannot find moon.mod.json in')) {
  throw new Error(`Unexpected error output:\n${output}`);
}
