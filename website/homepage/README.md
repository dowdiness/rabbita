# Rabbita website

Built with MoonBit, Rabbita, and Warren.

## Setup

```sh
moon update
moon install moonbit-community/warren
```

## Dev

```sh
moon run --target native scripts/assets.mbtx
warren dev main --public-dir public
```

## Build

```sh
moon run --target native scripts/assets.mbtx
warren build main --dist dist
```
