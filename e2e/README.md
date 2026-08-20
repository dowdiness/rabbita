# End-to-end tests

The Playwright suite starts dedicated MoonBit applications under `apps/` with
Warren and tests them in Chromium. These fixtures belong to the test suite and
do not depend on applications under `examples/`.

Each application uses Warren's minimized root-package layout. The initial
fixtures are:

- `apps/counter` on port `4300`
- `apps/toggle` on port `4301`

## Prerequisites

- Node.js 22 or newer
- MoonBit
- Warren installed from this checkout. Run this from the repository root:

  ```sh
  moon install ./warren
  ```

## Setup

From the `e2e` directory:

```sh
npm ci
npx playwright install chromium
```

## Run

```sh
npm test
```

Playwright starts each application on its configured port. During local
development it reuses servers already listening at those addresses.

Additional commands:

```sh
npm run test:headed
npm run test:ui
npm run report
```

Tests should prefer accessible roles, labels, and visible text. Add a
`data-testid` only when the user-facing semantics cannot provide a stable
locator.

## Add an application

1. Create a minimized Warren application under `apps/<name>`.
2. Add it to the repository workspace with `moon work use e2e/apps/<name>`.
3. Add its name and a unique port to `apps` in `playwright.config.ts`.
4. Add `tests/<name>.spec.ts`; the matching Playwright project will run it.
