# rabbita-vite-plugin

Vite plugin for Rabbita applications built with MoonBit.

## What it handles

- Modern MoonBit output layout: `_build/js/<debug|release>/build`
- Main-package discovery via build metadata (`_build/packages.json`), so both `moon.pkg` and legacy `moon.pkg.json` projects work
- Parent workspaces discovered via `moon.work`, with `_build` lookup falling back to the local module

## Install

```bash
npm i -D @rabbita/vite
```

## Usage

```ts
import { defineConfig } from 'vite'
import rabbita from '@rabbita/vite'

export default defineConfig({
  plugins: [rabbita()],
})
```

The current Vite directory must contain `moon.mod.json`.

If a parent `moon.work` exists, the plugin still runs `moon build` in the
current module directory, then looks for generated artifacts in this order:

1. the parent workspace `_build`
2. the current module `_build`

## Select the main package in Vite (optional)

If your module has multiple `is-main` packages, pass `main` to
choose one:

```ts
import { defineConfig } from 'vite'
import rabbita from '@rabbita/vite'

export default defineConfig({
  plugins: [rabbita({ main: 'relative/path/to/main2' })],
})
```

`main` is the package directory path relative to the current module root
(for example: `main2` or `apps/web`).
