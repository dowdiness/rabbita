# Subscription Example

This example shows how to use Rabbita subscriptions in a browser app.

It demonstrates:

- `@sub.every(1000, ...)` for a ticking counter
- `@sub.on_resize(...)` for window resize events
- `subscriptions=` changing with model state when the timer is paused or resumed

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
