import { defineConfig } from '../../../../website/node_modules/vite/dist/node/index.js';
import rabbita from '../../../src/index';

export default defineConfig({ plugins: [rabbita()] });
