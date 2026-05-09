# Rabbita MoonBit Playground

This playground shell is written in MoonBit + Rabbita. The left pane edits
`main.mbt`, `index.html`, `style.css`, and `moon.pkg`; the right pane renders
the compiled program in an iframe.

The browser compiler bridge is a small static JavaScript runtime around
`moonc-worker`. There is no npm, package.json, Node package script, Python
entrypoint, or Moon wrapper script.

`dist/` is the final static site root. After building, the app must not depend
on any local file outside `dist/`.

Generated runtime assets live under `dist/`:

- `dist/index.html`
- `dist/styles.css`
- `dist/app.js`
- `dist/support/`
- `dist/moonbit-assets/`
- `dist/vendor/moonc-worker.js`
- `dist/repo-examples/`

## Run

Generate compiler assets after setting the asset input paths described below:

```sh
moon run --target native scripts/assets.mbtx
```

Build the playground shell and bundled examples:

```sh
moon run --target native scripts/build.mbtx
```

Serve locally:

```sh
moon run --target native scripts/serve.mbtx 5174
```

Open:

```text
http://127.0.0.1:5174
```

## Asset Inputs

`scripts/assets.mbtx` needs a local MoonBit compiler worker and a local core
bundle. Provide those paths explicitly:

```sh
MOONBIT_PLAYGROUND_WORKER=/path/to/moonc-worker.js \
MOONBIT_PLAYGROUND_CORE_BUNDLE=/path/to/core/bundle \
MOON_BIN=/path/to/moon \
moon run --target native scripts/assets.mbtx
```

`scripts/build.mbtx` copies `public/` and `support/` into `dist/`, builds
`dist/app.js`, and bundles repository examples into `dist/repo-examples/`.
