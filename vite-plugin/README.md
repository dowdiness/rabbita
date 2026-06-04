# rabbita-vite-plugin

Vite plugin for Rabbita applications built with MoonBit.

## What it handles

- Runs `moon build --target js --target-dir <tmp>` for plugin-owned output
- Uses debug output during `vite dev` and release output during `vite build`
- Finds generated JS with `find` under `<tmp>/js/<debug|release>/build`
- Relies on Vite's default dev-server watcher for live reload
- Does not parse MoonBit project config files to infer source directories

## Install

```bash
npm i -D @rabbita/vite
```

## Usage

```ts
import { defineConfig } from 'vite'
import rabbita from '@rabbita/vite'

export default defineConfig({
  plugins: [rabbita({ mainPkgDir: 'src/main' })],
})
```

`mainPkgDir` is a filesystem path relative to the Vite config file. The
plugin runs `moon build .` inside that directory.

`mainPkgDir` must stay inside the directory that contains `vite.config.*`.
MoonBit files outside that directory are intentionally unsupported.

If `mainPkgDir` is omitted, the plugin runs `moon build` in the Vite root
and the build must produce exactly one JS file. In that mode, the Vite root is
also treated as the MoonBit build directory and must stay inside the Vite config
directory.

For live reload, the plugin does not add custom dev-server watch roots. It
rebuilds only when Vite reports a MoonBit file change through its watcher.

If your HTML lives in a subdirectory, keep Vite `root` at the project directory
and point Rollup at the HTML entry:

```ts
export default defineConfig({
  build: {
    rollupOptions: {
      input: 'app/index.html',
    },
  },
  plugins: [rabbita({ mainPkgDir: '.' })],
})
```

If the host filesystem does not emit native change events reliably, configure
Vite's own watcher, for example `server.watch.usePolling`. The plugin does not
force polling.

## Deprecated compatibility options

`main` and `moonModDir` are kept for compatibility, but new projects should use
`mainPkgDir`.

```ts
import { defineConfig } from 'vite'
import rabbita from '@rabbita/vite'

export default defineConfig({
  plugins: [rabbita({ main: 'moonbitlang/mooncakes/main' })],
})
```

For `main`, the plugin first searches generated JS output with the full
selector. If that fails and the selector has a `user/name/...` prefix, it also
tries the path after the first two segments, so `moonbitlang/mooncakes/main`
can match `main/main.js`.
