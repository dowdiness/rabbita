import { defineConfig } from 'vite';
import rabbita from '../../src/index';

export default defineConfig({
    build: {
        outDir: 'dist-legacy',
    },
    plugins: [
        rabbita({ main: 'username/rabbita-tailwind/main2' }),
    ],
});
