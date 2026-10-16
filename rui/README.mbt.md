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

Call `sonner_host(build=scope => (content, focus_policy))` during composition.
`build` runs exactly once: construct application state there, capturing the
scope in its update closure, and return its `Val[Html]` and `() -> Cmd` focus
policy. The host combines content and notifications with `Val::map2`. Return
`scope.show(...)` or `scope.dismiss_all()` as application commands. Do not create
application state inside `sonner`'s children callback: that callback is a render
function and may run again.

The existing `sonner(children)` and `toaster(children)` APIs remain available.
Hosts retain a bounded set of hidden DOM slots after notifications close, so
notification expiry does not break native Undo grouping in adjacent editors.
Only visible slots are exposed to keyboard navigation and accessibility APIs.

Return `() => emit(FocusCurrentTarget)` from `build` so focus decisions use
current application state. The rendering forms `sonner` and `toaster` also take
`on_focus_return=() => focus_command`. The callback is
captured by composition, never stored in Model. It runs when a focused
notification starts closing, or its focused slot becomes hidden. Replacement
in a retained visible slot preserves focus and does not invoke the callback.
Expiry while focus is elsewhere never invokes it. There is no default focus
target: applications should provide their own mode-aware command.

Hover and focus pause belong to retained DOM slots, while timers and swipe
gestures belong to notification IDs. Replacing a notification under stationary
hover or focus keeps the host paused; hiding a slot clears its pause sources.
Timeouts that elapse while paused dismiss on resume (they do not restart).
Each host has independent local pause ownership and receives document pause
events independently, even when several Sonner hosts share a document.

## License

RUI is available under the [MIT License](./LICENSE). See
[`THIRD_PARTY_NOTICES.md`](./THIRD_PARTY_NOTICES.md) for upstream attribution.
