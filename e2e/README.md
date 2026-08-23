# End-to-end tests

The Playwright suite starts dedicated MoonBit applications under `apps/` with
Warren and tests them in Chromium. These fixtures belong to the test suite and
do not depend on applications under `examples/`.

Each application uses Warren's minimized root-package layout. The fixtures are:

- `apps/counter` on port `4300`
- `apps/state-and-messages` on port `4301`
- `apps/forms-and-events` on port `4302`
- `apps/collections-lifecycle` on port `4303`
- `apps/navigation-history` on port `4304`
- `apps/commands-and-async` on port `4305`
- `apps/http` on port `4306`
- `apps/subscriptions` on port `4307`
- `apps/dom-api` on port `4308`
- `apps/mount-lifecycle` on port `4309`

The suite covers stable public behavior: state and message composition, forms
and DOM events, incremental collection lifecycles, same-origin navigation,
commands and asynchronous work, mocked HTTP, subscription lifecycles, and
mounted application teardown. It also exercises the public DOM bindings against
real browser objects. It does not assert ordering for batched or nested
messages.

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

Keep tests deterministic. Mock HTTP with Playwright routes, use the Playwright
clock for timers, and rely on retrying assertions or event-driven barriers
instead of fixed sleeps.

## Add an application

1. Create a minimized Warren application under `apps/<name>`.
2. Add it to the repository workspace with `moon work use e2e/apps/<name>`.
3. Add its name and a unique port to `apps` in `playwright.config.ts`.
4. Add `tests/<name>.spec.ts`; the matching Playwright project will run it.
