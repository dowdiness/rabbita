# RUI

RUI (`Yoorkin/rui`) is a native component library for
[Rabbita](https://github.com/moonbit-community/rabbita). It brings the
shadcn/ui **Vega** visual language and compound component conventions to
MoonBit while keeping rendering, state, and interaction inside Rabbita.

Components are ready to use as black boxes by default. Use the public API for
ordinary customization, or copy a component's source when you need to change
its structure or state model. RUI follows familiar shadcn/ui organization, but
it is not a drop-in port of the React implementation.

## Highlights

- No Tailwind, PostCSS, code generator, or build plugin.
- No CSS file to import.
- Vega-style light and dark themes with overridable CSS custom properties.
- Interactive components own their state through Rabbita incremental values.
- Native HTML, ARIA, Dialog, and Popover semantics where the browser already
  provides the correct behavior.
- JavaScript interaction and native-target initial HTML for SSR.
- Consistent `data-slot` attributes for testing and application-level styling.
- MIT-licensed component source that can be copied for deep customization.

## Installation

Add Rabbita and RUI to your application's `moon.mod`:

```mbt nocheck
import {
  "moonbit-community/rabbita@0.13.1",
  "Yoorkin/rui@0.1.0",
}
```

Import the packages used by your view from `moon.pkg`:

```mbt nocheck
import {
  "moonbit-community/rabbita",
  "moonbit-community/rabbita/html",
  "Yoorkin/rui",
}
```

RUI does not require initialization or a CSS import. Component base recipes are
inline. Wrap the rendered HTML root in `theme` once to provide the selected
theme tokens, hover states, focus rings, and animations to the subtree:

```mbt nocheck
@rui.theme(
  @rui.card([
    @rui.card_header([
      @rui.card_title("Account"),
      @rui.card_description("Manage your sign-in information."),
    ]),
    @rui.card_content([
      @rui.input(placeholder="name@example.com"),
      @rui.button("Save changes"),
    ]),
  ]),
)
```

## State model

Presentation components such as `button`, `card`, `input`, `separator`, and
`table` return `@html.Html` directly.

Interactive components return `@rabbita.Val[@html.Html]`. They keep their state
inside the component: `default_*` parameters provide initial values, while
`on_*_change` callbacks observe state updates without transferring state
ownership to the caller.

An interactive component can be used as the complete view or embedded in
surrounding HTML with `Val::view`:

```mbt nocheck
fn notification_settings() -> @rabbita.Val[@html.Html] {
  let notifications = @rui.switch(
    default_checked=true,
    aria_label="Receive notifications",
  )
  notifications.view(control =>
    @rui.theme(
      @rui.card([
        @rui.card_header(@rui.card_title("Notifications")),
        @rui.card_content(
          @rui.label([
            control,
            @html.text("Receive product notifications"),
          ]),
        ),
      ]),
    )
  )
}
```

`theme` returns `@html.Html`, while interactive components return
`@rabbita.Val[@html.Html]`. Compose an interactive value first, then apply
`theme` inside its `view` callback, as in the example above.

Use `Val::view2` through `Val::view9` when a view combines several independent
interactive components.

Stateful compound components often receive an opaque scope. The scope connects
their parts to one internal state owner without exposing implementation details:

```mbt nocheck
@rui.radio_group(
  default_value="pro",
  name="plan",
  aria_label="Plan",
  scope => [
    @rui.radio_group_item(scope~, value="free", aria_label="Free"),
    @rui.radio_group_item(scope~, value="pro", aria_label="Pro"),
  ],
)
```

Select and Combobox include ready-to-use renderers and also accept scoped render
functions. Components such as Radio Group, menus, Dialog, and Sidebar expose
opaque builder scopes so their parts share one internal state owner. Popover,
Hover Card, and Tooltip accept their trigger and content directly instead.

## Themes and customization

Component recipes use `--rui-*` custom properties and include neutral fallback
values. `theme` supplies the selected light or dark token set together with the
CSS selectors needed for hover, focus-visible, open, checked, and selected
states.

Override tokens on `theme` to customize an entire subtree:

```mbt nocheck
@rui.theme(
  mode=@rui.Dark,
  style=[
    "--rui-primary:oklch(0.62 0.19 265)",
    "--rui-primary-foreground:white",
    "--rui-radius:0.75rem",
  ],
  @rui.button("Continue"),
)
```

Visual components also accept a `style` array. User styles are appended after
the built-in recipe, so later declarations override matching properties:

```mbt nocheck
@rui.button(
  style=["background:rebeccapurple", "border-radius:2px"],
  "Custom button",
)
```

Use `attrs` for additional HTML, ARIA, event, and `data-*` attributes. Components
copy caller-provided attributes before adding their own values. Avoid managing
the same CSS property through both the component's `style` parameter and
`Attrs::style`, because they belong to different VDOM update paths.

The Vega font stack starts with Inter, but RUI does not download a font. It
falls back to the host application's system sans-serif stack when Inter is not
available.

## Components

The live [component catalog](https://moonbit-community.github.io/rabbita/components/)
shows each component, its variants, and copyable MoonBit examples. The generated
`pkg.generated.mbti` file is the source of truth for exact public signatures.

| Category | Components |
|---|---|
| Foundations | Aspect Ratio, Avatar, Badge, Button, Button Group, Direction, Kbd, Label, Separator, Skeleton, Spinner, Toggle, Toggle Group |
| Forms | Calendar, Checkbox, Combobox, Date Picker, Field, Form, Input, Input Group, Input OTP, Native Select, Radio Group, Select, Slider, Switch, Textarea |
| Data and content | Alert, Attachment, Bubble, Card, Chart, Data Table, Empty, Item, Marker, Message, Message Scroller, Progress, Resizable, Scroll Area, Table, Typography |
| Navigation and disclosure | Accordion, Breadcrumb, Carousel, Collapsible, Navigation Menu, Pagination, Sidebar, Tabs |
| Overlays and menus | Alert Dialog, Command, Context Menu, Dialog, Drawer, Dropdown Menu, Hover Card, Menubar, Popover, Sheet, Tooltip |
| Feedback | Sonner, Toast, Toaster |

Compound APIs mirror familiar shadcn/ui part names. For example, Card exposes
Header, Title, Description, Action, Content, and Footer; menu components expose
Group, Item, CheckboxItem, RadioGroup, RadioItem, Label, Separator, Shortcut,
and Sub; Sidebar exposes Provider, Trigger, Rail, Header, Footer, Content,
Group, and menu parts.

Higher-level components are self-contained. Data Table does not require TanStack
Table, Date Picker does not require React DayPicker, Carousel does not require
Embla, and Sonner/Toaster do not create a global JavaScript singleton.

## Interaction and accessibility

RUI uses native browser behavior where possible and fills in the state and
keyboard behavior required by compound widgets:

- Buttons, inputs, textareas, native selects, and radios preserve native form
  and keyboard semantics.
- Dialog, Alert Dialog, Sheet, Drawer, and Command Dialog use the browser's
  top-layer dialog behavior for Escape handling, focus boundaries, and focus
  restoration.
- Popover, Hover Card, Tooltip, and menu surfaces use native floating/top-layer
  primitives with Rabbita-owned open state and, for menus, active-item state.
- Menu, Command, Combobox, and Select support their applicable ARIA roles,
  arrow keys, Home/End, Enter, Escape, roving focus, or active-option behavior.
- Tabs support arrow-key and Home/End navigation. Calendar supports a single
  tab stop, arrow keys, Home/End, PageUp/PageDown, and cross-month focus
  movement.
- Disabled, read-only, invalid, mixed, pressed, checked, and selected states are
  reflected through the applicable native, ARIA, and `data-*` attributes.
- Motion respects `prefers-reduced-motion`.

## Rendering targets

The JavaScript target provides browser events and interactive state updates.
On the native target, interactive components expose their initial state as a
constant Rabbita value for SSR and snapshot rendering; they do not emulate
browser interaction inside the server process.

## Showcase

Browse the hosted [Components pages](https://moonbit-community.github.io/rabbita/components/)
for interactive variants and copyable MoonBit examples. Each example calls the
same public RUI API that applications use and matches the rendered result.

## Current limitations

- A single `theme` wrapper is required for pseudo-classes, media queries, and
  keyframe animations. These rules cannot be expressed in an HTML `style`
  attribute, so `theme` emits one static internal stylesheet; it does not use a
  runtime registration system.
- Modern browser support for native Dialog and Popover primitives is expected.
- Drawer uses native dialog behavior and does not reproduce Vaul drag velocity
  or snap points.
- Chart provides themed container, tooltip, and legend surfaces. Supply your
  own SVG, Canvas, or charting engine for the actual visualization.

## Deep customization

Start with theme tokens, component `style`, `attrs`, and compound builders. If
you need a different DOM structure, sizing system, state machine, or interaction
policy, copy the relevant `.mbt` source into your application and maintain it
locally.

There is no vendor synchronization, style registration, generator, or
additional build convention to keep in sync.

## Upstream and license

RUI follows the current [shadcn/ui component documentation](https://ui.shadcn.com/docs/components)
and [shadcn/ui source](https://github.com/shadcn-ui/ui) for the Vega visual
language and compound API conventions.

RUI is implemented for Rabbita and is not affiliated with shadcn/ui. The module
is available under the [MIT License](./LICENSE). See
[`THIRD_PARTY_NOTICES.md`](./THIRD_PARTY_NOTICES.md) for upstream copyright and
attribution notices.
