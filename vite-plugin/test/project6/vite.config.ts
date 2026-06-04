import { defineConfig } from 'vite';
import rabbita from '../../src/index';

export default defineConfig({
  build: {
    outDir: 'dist',
    rollupOptions: {
      input: 'app/index.html',
    },
  },
  plugins: [
    rabbita({ mainPkgDir: '.' }),
  ],
});
