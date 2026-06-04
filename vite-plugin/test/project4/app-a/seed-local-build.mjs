import fs from 'node:fs';
import path from 'node:path';

const buildRoot = path.join(process.cwd(), '_build');
const buildDir = path.join(buildRoot, 'js', 'release', 'build', 'test', 'project4-a', 'main');

fs.mkdirSync(buildDir, { recursive: true });
fs.writeFileSync(
  path.join(buildDir, 'main.js'),
  [
    'const mount = document.getElementById("app");',
    'if (mount) {',
    '  mount.textContent = "local override project4 app-a";',
    '}',
    'export {};',
    '',
  ].join('\n'),
);
