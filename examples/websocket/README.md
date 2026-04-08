# WebSocket Chat Demo

This example is meant to exercise both WebSocket APIs in Rabbita without
introducing a local server:

- `@websocket.listen(...)` on the watcher panel
- `@websocket.connect/send/close/state(...)` on the chat client panel

Both panels point at the same public echo endpoint by default:
`wss://echo-websocket.fly.dev`

That endpoint echoes whatever the command client sends, so the page works as a
small self-echo chat demo:

- use the watcher to see how a subscription socket reacts to `open`, `message`,
  `close`, and `error`
- use the cmd client to connect explicitly, send JSON chat frames or raw text,
  close the socket, and inspect state snapshots

The watcher and the cmd client are intentionally separate sockets. That makes
the example useful for demoing and testing both styles side by side.

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
