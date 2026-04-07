import fs from 'node:fs';
import path from 'node:path';

const assetsDir = path.join(process.cwd(), 'dist', 'assets');
const files = fs.readdirSync(assetsDir).filter(file => file.endsWith('.js'));
if (files.length === 0) {
  throw new Error(`No built JS asset found in ${assetsDir}`);
}

const content = files
  .map(file => fs.readFileSync(path.join(assetsDir, file), 'utf8'))
  .join('\n');

if (!content.includes('local project4 app-a')) {
  throw new Error('Expected workspace _build output to resolve to app-a');
}
if (content.includes('workspace project4 app-b')) {
  throw new Error('Expected main package selection to stay on app-a');
}
if (content.includes('local override project4 app-a')) {
  throw new Error('Expected workspace _build to be preferred over local fallback output');
}
