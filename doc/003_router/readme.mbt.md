# Router

This tour describes when to use a router and how to write an app with a router in Rabbita.

Rabbita adopts an Elm-style router. There is no hidden `router` object, and you are required to manage routing explicitly:

* Treat the current route as part of the Model
* Use URL parsing (pattern matching or modules like `sw_router`)
* Use `UrlChanged`/`UrlRequest` to drive the `update` function and update route state.

## Register the route messages

Use the root cell's `subscriptions` callback together with
`@sub.on_url_changed(...)` and `@sub.on_url_request(...)` to declare which
messages should be triggered for routing events.

The `url_request` is a navigation **intention** (captured link click), and
the `url_changed` is a navigation **fact** (the browser location has already changed).
We’ll cover the details later.

Now we can define the `UrlChanged` and `UrlRequest` messages like this:  

```moonbit check
///|
enum Msg {
  UrlChanged(Url)
  UrlRequest(UrlRequest)
}
```

To register the `UrlChanged` and `UrlRequest` messages, use
`cell_with_emit(...)` to obtain the main cell and the corresponding
`emit` function, then wire the route subscriptions on the root cell:

```moonbit check
///|
test {
  fn subscriptions(emit : Emit[Msg], _ : Model) -> @sub.Sub {
    @sub.batch([
      @sub.on_url_changed(url => emit(UrlChanged(url))),
      @sub.on_url_request(req => emit(UrlRequest(req))),
    ])
  }

  let (_emit, root) = @rabbita.cell_with_emit(
    model=home,
    subscriptions~,
    update~,
    view~,
  )
  ignore(root)
}
```

What about `model`, `update`, and `view`? The following sections show how to define these components for routing.

## Sketch the app model

Here we sketch a site with three pages:

* `/home`: the main page that lists the article links
* `/article/id`: the article page, displaying the title and content
* Any other path displays the 404 not found page

We can use an `enum` to represent this:

```moonbit check
///|
type Id = String

///|
enum Model {
  Home(Map[Id, String])
  Article(String, String)
  NotFound
}
```

We skipped the networking part in this tutorial, so let's hardcode the data as globals:

```moonbit check
///|
let home : Model = Home({ "1": "Article 1", "2": "Article 2", "3": "Article 3" })

///|
let articles : Map[String, (String, String)] = {
  "1": ("Article 1", "content 1"),
  "2": ("Article 2", "content 2"),
  "3": ("Article 3", "content 3"),
}
```

## Define the update function and routing logic

The `update` function handles routing by responding to `UrlRequest` and `UrlChanged` messages. 

- `UrlRequest`

  Triggered when the user intends to navigate, usually by clicking a captured `@html.a(...)`. This represents a navigation request, and the application can decide how to handle it.

  `UrlRequest` is an enum:
  - `Internal(Url)`: the target URL is within the same domain (SPA navigation)
  - `External(String)`: the target URL points to another site (full page load)
  
  Since this is only an intention, the app may:
  - allow the navigation
  - redirect
  - block it
  - handle it in a custom way

- `UrlChanged`

  Triggered when the browser URL has already changed. This can happen because of:

  - the browser forward/back button
  - commands made by `@nav.push_url(...)` / `@nav.replace_url(...)`
  - manual address bar changes

  The Url represents the current browser location. At this point, navigation has already occurred, and the app should update its Model (e.g. parse the URL and update the Route).

When a user clicks a link or the URL changes, the function updates the model based on the new route.
For internal links, it uses `@nav.push_url` to change the URL without reloading the page. For external links, it uses `@nav.load` to navigate away. When the URL changes, the function matches the path and updates the model to display the correct page or a 404 page if the route is not found.

```moonbit check
///|
fn update(_ : Emit[Msg], msg : Msg, model : Model) -> (Cmd, Model) {
  match msg {
    // handle clicks on @html.a(...) link
    UrlRequest(request) =>
      match request {
        // use @nav.push_url(...) to trigger the UrlChanged
        Internal(url) => (@nav.push_url(url.to_string()), model)
        // navigate away
        External(url) => (@nav.load(url), model)
      }
    // handle route url changes
    UrlChanged(url) =>
      match url.path {
        "/" | "/home" => (none, home)
        [.. "/article/", .. id] if articles.get(id.to_owned())
          is Some((title, content)) => (none, Article(title, content))
        _ => (none, NotFound)
      }
  }
}
```

## Define the view

The `view` function renders UI based on the current `Model`.  
In this example, the `Model` represents the current route, so the view is effectively determined by the active page.

Notice that `view` is a pure function: it does not perform navigation or modify state directly.  
Instead, navigation is triggered by links (`a(href=...)`), which produce a `url_request` message.

```moonbit check
///|
fn view(_ : Emit[Msg], model : Model) -> Html {
  match model {
    Home(items) =>
      ul(items.map((id, title) => li(a(href="/article/\{id}", title))))
    Article(title, content) => div([h1(title), p(content)])
    NotFound => div([h1("404"), a(href="/home", "go home")])
  }
}
```

# When should you use a router?

You don’t need a router at the beginning.

In Rabbita, routing is just state derived from the URL. If your app only switches views locally and does not need deep links, browser refresh recovery, or back/forward support, normal messages and model updates are enough.

Introduce a router only when navigation becomes part of your app’s public state.  Routing should feel like a natural refactor as the app grows, not something you design upfront.

# Core Idea Recap

- The current page lives in the Model
- Navigation is expressed as messages
- URL changes update the model
- The view is a pure projection of model

There is no hidden router object, routing is just model + messages + update.
