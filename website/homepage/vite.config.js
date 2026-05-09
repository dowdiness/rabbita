import { defineConfig } from 'vite'
import rabbita from '@rabbita/vite'
import { join, sep } from 'path'
import { cpSync } from 'fs'

function skipBuildCache(source) {
  const parts = source.split(sep)
  return !parts.includes('_build') && !parts.includes('.mooncakes')
}

export default defineConfig({
  base: './',
  publicDir: false,
  plugins: [
    rabbita(),
    {
      name: 'copy-static-assets',
      closeBundle() {
        const publicDir = join(process.cwd(), 'public')
        const distDir = join(process.cwd(), 'dist')
        cpSync(join(publicDir, '404.html'), join(distDir, '404.html'))
        cpSync(join(publicDir, 'mooncakesio.jpeg'), join(distDir, 'mooncakesio.jpeg'))
        cpSync(join(publicDir, 'rabbita.jpeg'), join(distDir, 'rabbita.jpeg'))
        cpSync(
          join(process.cwd(), '../../doc'),
          join(distDir, 'doc'),
          { recursive: true, filter: skipBuildCache },
        )
      },
    },
  ],
  server: {
    host: true,
    fs: { allow: ['../..'] },
  },
})
