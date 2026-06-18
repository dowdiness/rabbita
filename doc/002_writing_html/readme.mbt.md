# Writing HTML Views

This tutorial explains how to build views with Rabbita's `@html` package. You will learn:

- How to describe UI structure with HTML wrapper functions
- Which types can be passed as `Children`
- When to use `text()` and `nothing`
- How to use keyed children
- How to bind events
- When to use `Attrs::build()` and `node()`

## Start with a minimal view

`@html` provides wrapper functions for common HTML tags. Frequently used attributes 
and events are usually available as optional parameters.

```moonbit check
///|
enum Msg {
  Inc
  Dec
}

///|
struct Model {
  count : Int
}

///|
fn view(emit : Emit[Msg], model : Model) -> Html {
  div(id="counter", style=["border: 1px solid #ddd", "padding: 8px"], [
    h1("count = \{model.count}"),
    button(on_click=emit(Inc), "+"),
    button(on_click=emit(Dec), "-"),
  ])
}
```

## Four common `Children` forms

Most HTML wrapper functions accept a positional argument constrained by `IsChildren`, so multiple types are valid.

| Type | Example |
| - | - |
| `Array[Html]` | `div([p("a"), p("b")])` |
| `String` | `div("plain text")` |
| `Html` | `div(p("single child"))` |
| `Map[String, Html]` | `ul({"k1": li("a"), "k2": li("b")})` |

```moonbit check
///|
let children_array : Html = div([p("line 1"), p("line 2")])

///|
let children_text : Html = div("plain text child")

///|
let single_child : Html = div(p("single child"))

///|
let keyed_children : Html = ul({
  "todo-1": li("Buy milk"),
  "todo-2": li("Write docs"),
})
```

## `text()` and `nothing`

- `text("...")` explicitly creates a text node
- `nothing` means "render nothing here", useful for optional branches

```moonbit check
///|
fn tag_view(tag : String?) -> Html {
  match tag {
    None => nothing
    Some(t) => span(class="tag", t)
  }
}

///|
fn card_view(tag : String?) -> Html {
  div([h2("Article"), tag_view(tag), p([text("Hello"), text(" world")])])
}
```

## Keyed children

When children are passed as `Map[String, Html]`, Rabbita treats them as keyed children.

- Keys should be unique and stable (prefer business IDs)
- Do not use changing list positions as keys
- Changing a key means removing the old node and creating a new one

```moonbit check
///|
fn todo_list(items : Map[String, String]) -> Html {
  ul(items.map((id, title) => li("(\{id}) \{title}")))
}
```

## Event handling

Event arguments are typically functions returning `Cmd`. You can forward events as messages and keep state changes centralized in `update`.

```moonbit check
///|
enum DrawMsg {
  Start(@html.Mouse)
  End(@html.Mouse)
}

///|
fn handle_draw(msg : DrawMsg) -> Unit {
  match msg {
    Start(mouse) => ignore(mouse)
    End(mouse) => ignore(mouse)
  }
}

///|
fn canvas_view(emit : Emit[DrawMsg]) -> Html {
  canvas(
    on_mousedown=m => emit(Start(m)),
    on_mouseup=m => emit(End(m)),
    nothing,
  )
}
```

Use pointer events for unified mouse, touch, and stylus input. `div` and
`canvas` expose `on_pointerdown`, `on_pointerup`, and `on_pointermove`; the
payload is `@html.Pointer`, whose `offset_pos()`, `client_pos()`, and
`screen_pos()` follow the same coordinate-space conventions as `Mouse`.

## Attribute Builder

If a wrapper function does not expose a required attribute or event, use `Attrs::build()` as a fallback.

```moonbit check
///|
let card_html : Html = div(
  attrs=Attrs::build()
    .class("card card--elevated")
    .id("profile-card")
    .title("User profile card")
    .data_set("kind", "profile")
    .style("gap", "12px")
    .style("padding", "12px"),
  [p("Hello Rabbita")],
)
```

## Escape hatch: `node()`

If a tag or capability is missing from wrappers, use `node()` to manually define tag, attrs, and children.

```moonbit check
///|
let custom_node_html : Html = node(
  "section",
  Attrs::build()
  .class("card custom-block")
  .data_set("source", "node")
  .style("border", "1px solid #ddd")
  .style("padding", "12px"),
  [h2("Custom Node"), p("built with node()")],
)
```

## Practical guidance

- Prefer wrapper optional parameters first (best readability and type experience)
- Use `Attrs::build()` only when wrapper options are missing
- Use `node()` when a tag is not provided
- For dynamic lists with insert/remove/reorder, prefer keyed children
