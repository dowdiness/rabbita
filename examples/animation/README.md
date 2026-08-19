# Animation Example

This example isolates Rabbita's `on_animation_frame` subscription.

It starts on the rabbit tangram and lets you switch patterns manually while the
frame subscription drives the current transition.

Third-party notice:

- `main/logo_animation.mbt` adapts code from `elm/elm-lang.org`
- see [THIRD_PARTY_NOTICES.md](./THIRD_PARTY_NOTICES.md)

## Run in development

In this directory:

```bash
moon install moonbit-community/warren
warren dev --browser-entry main
```

Then open the local URL shown by warren.
