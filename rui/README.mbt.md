# RUI (Experimental)

> RUI is experimental. Its API and component behavior may change before a
> stable release.

RUI (`moonbit-community/rui`) is a native component library for
[Rabbita](https://github.com/moonbit-community/rabbita), inspired by the
[shadcn/ui Nova](https://ui.shadcn.com/r/styles/base-nova/registry.json) visual language.

[Browse the component showcase](https://moonbit-community.github.io/rabbita/components/)

## Design

- Black-box components with public APIs for common customization.
- No Tailwind, external CSS import, code generator, or extra build step.
- Shared inline base styles, with `theme` providing tokens and the static rules
  needed for hover, focus, and motion.
- Interactive state is owned by Rabbita incremental components.
- Native HTML and ARIA behavior is used where the browser provides it.
- JavaScript provides browser interaction.

RUI includes components for forms, data display, navigation, disclosure,
overlays, menus, and feedback. Exact APIs and copyable examples are available
in the [showcase](https://moonbit-community.github.io/rabbita/components/) and
the generated `pkg.generated.mbti` interface.

## Customization

For Markdown documents, import `moonbit-community/rui/markdown` and use
`@markdown.markdown(source)`. The synchronous renderer includes shadcn Typeset typography with Nova tokens,
tables, task lists and footnotes. See the [Markdown package](markdown/README.mbt.md)
for supported syntax and source-rendering behavior.

Use `--rui-*` theme tokens, component `style` parameters, and `attrs` for normal
customization. Copy the relevant `.mbt` source when you need to change a
component's DOM structure, state model, or interaction policy.

## Notifications in an existing stateful application

Call `sonner_host()` once during component composition to obtain
`(Val[Html], ToastScope)`. Capture the scope in the application's update closure
and return `scope.show(...)` or `scope.dismiss_all()` as commands. Combine the
returned host view with the application's view using `Val::map2`. Do not create
application state inside `sonner`'s children callback: that callback is a render
function and may run again.

The existing `sonner(children)` and `toaster(children)` APIs remain available.

## License

RUI is available under the [MIT License](./LICENSE). See
[`THIRD_PARTY_NOTICES.md`](./THIRD_PARTY_NOTICES.md) for upstream attribution.
