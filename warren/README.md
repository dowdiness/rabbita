# warren

`warren` helps you preview and build MoonBit web applications.

Use it during development for a local browser preview with live reload, and use it before publishing to create a static output directory.

## Install

Install with Moon:

```sh
moon install moonbit-community/warren
```

This gives you the `warren` command.

## New Project

Create a Rabbita app:

```sh
warren new my-app
cd my-app
warren dev
```

Choose the smaller bundled template when needed:

```sh
warren new my-app --template minimized
```

## Development Preview

Run inside your app directory:

```sh
warren dev
```

Then open the printed local URL in your browser.

By default, `warren dev` uses:

- `./main` as the main package directory when it exists
- the current directory otherwise
- `./public` for static files when it exists
- port `4300`

You can also choose the main package, static files directory, or port:

```sh
warren dev path/to/main --public-dir path/to/public --port 4301
```

If the port is already used by a previous `warren` preview, `warren` will stop it and continue. If another program is using the port, stop that program manually or choose a different port.

## Release Build

```sh
warren build
```

By default, `warren build` builds:

- `./main` when it exists
- the current directory otherwise

You can also pass the main package directory explicitly:

```sh
warren build path/to/main
```

The build output is written to `./dist` by default. You can choose another output path:

```sh
warren build --dist path/to/dist
warren build path/to/main --dist path/to/dist
```

If `public/` exists next to the app directory, its contents are copied into the output directory.

`warren build` tries to compress the generated JavaScript with `terser`.
If `terser` is not available, it falls back to the uncompressed release JS.

## `public/` Directory

`public/` is optional.

If you want to customize the page, create `public/` next to your app's main package and add:

- `public/index.html`
- `public/styles.css`

Common usage:

- Add `public/index.html` if you want to control the page structure
- Add `public/styles.css` if you want custom styles
- Both files are optional

When `public/index.html` is present, `warren` keeps your page and adds the app entry script when needed. When it is not present, `warren` creates a default page.

## Help

```sh
warren --help
warren new --help
warren dev --help
warren build --help
```
