import { defineConfig } from 'vite';
import rabbita from '../../src/index';

export default defineConfig({
  root: 'app',
  build: {
    outDir: '../dist',
  },
  plugins: [
    rabbita({ moonModDir: '.' }),
  ],
});
