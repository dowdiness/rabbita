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

if (!content.includes('project3 fallback app-a')) {
  throw new Error('Expected fallback build to use app-a local output');
}
