# Shiki Editor Example

This example is a browser app built with Rabbita + Shiki.

## Backend support

`utils/shiki` currently depends on `extern "js"` APIs, so this example is
**JS/browser-only** for now.

Do not run:

```bash
moon run ./main --target native
```

## Run in development

In this directory:

```bash
npm install
npm run dev
```

Then open the local URL shown by Vite (usually `http://localhost:5173`).

## Build

```bash
npm run build
```

The built assets are generated in `dist/`.
