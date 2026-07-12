import { spawn } from 'node:child_process';
import fs from 'node:fs/promises';
import path from 'node:path';

const sourcePath = path.resolve('main.mbt');
const viteCommand = process.platform === 'win32' ? 'vite.cmd' : 'vite';
const originalSource = await fs.readFile(sourcePath, 'utf8');
const originalText = '"moonModDir"';
const updatedText = '"viteWatcherUpdated"';
let output = '';
let exitStatus;
const hmrMessages = [];

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const server = spawn(
  viteCommand,
  ['--config', 'vite.watch.config.ts', '--host', '127.0.0.1', '--port', '5186', '--strictPort'],
  { cwd: process.cwd(), stdio: ['ignore', 'pipe', 'pipe'] },
);
const serverExited = new Promise(resolve => {
  server.on('exit', resolve);
});

server.stdout.setEncoding('utf8');
server.stderr.setEncoding('utf8');
server.stdout.on('data', chunk => { output += chunk; });
server.stderr.on('data', chunk => { output += chunk; });
server.on('exit', (code, signal) => { exitStatus = { code, signal }; });

async function waitFor(check, label, timeout = 20000) {
  const deadline = Date.now() + timeout;
  while (Date.now() < deadline) {
    if (exitStatus) {
      throw new Error(`${label} failed; vite exited: ${JSON.stringify(exitStatus)}\n${output}`);
    }
    if (await check()) {
      return;
    }
    await sleep(250);
  }
  throw new Error(`${label} timed out\n${output}\nHMR messages: ${JSON.stringify(hmrMessages)}`);
}

async function fetchJs() {
  try {
    const response = await fetch('http://127.0.0.1:5186/project6.js');
    return response.ok ? response.text() : '';
  } catch {
    return '';
  }
}

async function connectHmr() {
  const response = await fetch('http://127.0.0.1:5186/@vite/client');
  const clientCode = await response.text();
  const match = clientCode.match(/const wsToken = "([^"]+)"/);
  if (!match) {
    throw new Error('Cannot find Vite HMR websocket token');
  }

  const socket = new WebSocket(`ws://127.0.0.1:5186/?token=${match[1]}`, 'vite-hmr');
  socket.addEventListener('message', event => {
    hmrMessages.push(JSON.parse(event.data));
  });
  await waitFor(() => socket.readyState === WebSocket.OPEN, 'hmr websocket open');
  await waitFor(() => hmrMessages.some(message => message.type === 'connected'), 'hmr websocket connected');
  return socket;
}

try {
  await waitFor(() => output.includes('ready in'), 'vite dev startup');

  const initialJs = await fetchJs();
  if (!initialJs.includes('moonModDir')) {
    throw new Error('Expected initial JS to contain moonModDir');
  }
  const socket = await connectHmr();

  await sleep(3000);

  if (!originalSource.includes(originalText)) {
    throw new Error(`Cannot find ${originalText} in ${sourcePath}`);
  }
  await fs.writeFile(sourcePath, originalSource.replace(originalText, updatedText));

  await waitFor(async () => {
    const js = await fetchJs();
    return js.includes('viteWatcherUpdated');
  }, 'vite watcher rebuild', 30000);
  await waitFor(
    () => hmrMessages.some(message => message.type === 'full-reload'),
    'vite watcher full reload',
  );
  socket.close();
} finally {
  await fs.writeFile(sourcePath, originalSource);
  server.kill('SIGINT');
  await Promise.race([serverExited, sleep(3000)]);
  if (!exitStatus) {
    server.kill('SIGKILL');
  }
}
