import { spawnSync } from 'node:child_process';

const viteCommand = process.platform === 'win32' ? 'vite.cmd' : 'vite';

const noOutput = spawnSync(
  viteCommand,
  ['build'],
  { cwd: process.cwd(), encoding: 'utf8' },
);

const noOutputText = `${noOutput.stdout ?? ''}${noOutput.stderr ?? ''}`;
if (noOutput.status === 0) {
  throw new Error('Expected vite build to fail without generated JS output');
}

if (!noOutputText.includes('Cannot locate generated JS output under')) {
  throw new Error(`Unexpected error output:\n${noOutputText}`);
}

const mixedOptions = spawnSync(
  viteCommand,
  ['build', '--config', 'vite.mixed.config.ts'],
  { cwd: process.cwd(), encoding: 'utf8' },
);

const mixedOptionsText = `${mixedOptions.stdout ?? ''}${mixedOptions.stderr ?? ''}`;
if (mixedOptions.status === 0) {
  throw new Error('Expected vite build to fail when mixing mainPkgDir with deprecated options');
}

if (!mixedOptionsText.includes('Do not use mainPkgDir together with deprecated main or moonModDir options')) {
  throw new Error(`Unexpected mixed option error output:\n${mixedOptionsText}`);
}
