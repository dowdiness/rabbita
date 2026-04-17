# warren

`warren` is a small tool for previewing MoonBit web projects locally with live reload.

## Install

Install with Moon:

```sh
moon install moonbit-community/warren
```

This gives you the `warren` command.

## dev build

Run inside your MoonBit project:

```sh
warren dev
```

Then open the link in terminal.

Your project should have a runnable main package.

## release build

```sh
warren build
```

It builds the current module in release mode and writes the output to `dist/`.

`warren build` tries to compress the generated JavaScript with `terser`.
If `terser` is not available, it falls back to the uncompressed release JS.

## `public/` directory

`public/` is optional.

If you want to customize the page, create `public/` in your module root and add:

- `public/index.html`
- `public/styles.css`

Common usage:

- Add `public/index.html` if you want to control the page structure
- Add `public/styles.css` if you want custom styles
- Both files are optional

## Status

- [x] `warren dev`
- [ ] `moon.work` support
- [x] `warren build`
- [ ] AI debugging utils
