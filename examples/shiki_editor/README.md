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
moon install moonbit-community/warren
warren dev --browser-entry main
```

Then open the local URL shown by warren.
