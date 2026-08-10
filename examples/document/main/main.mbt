///|
using @rabbita {type Val, type Resource, none, batch, create_resource}

///|
#warnings("-unused_value")
using @html {
  type Html,
  title,
  div,
  h1,
  h2,
  button,
  p,
  ul,
  li,
  html,
  body,
  head,
  nothing,
  script,
}

///|
priv enum Msg {
  Inc
  Dec
  Repeat(Int, Msg)
}

///|
struct Issue {
  content : String
  status : String
} derive(FromJson, ToJson, Eq)

///|
fn app() -> Val[Html] {
  let (model, inject) = @rabbita.create_state_with_init(
    init=inject => (0, inject(Repeat(5, Inc))),
    update=(model, msg, inject) => {
      match msg {
        Repeat(0, _) => (model, none)
        Repeat(n, msg) =>
          (model, batch([inject(msg), inject(Repeat(n - 1, msg))]))
        Inc => (model + 1, none)
        Dec => (model - 1, none)
      }
    },
  )
  let issues : Resource[Array[Issue]] = create_resource(inject => {
    @http.get("/issues").expect_json(inject)
  })
  Val::map2(model, issues, (count, issues) => {
    let theme = if count % 2 == 0 { "dark" } else { "light" }
    html(attrs=@html.Attrs::build().data_set("theme", theme)) <| [
      head([
        title("\{count}"),
        script(src="/assets/index.js", type_="module", nothing),
      ]),
      body <| [
        div <| [
          h2("\{count}"),
          button(on_click=inject(Inc), "+"),
          button(on_click=inject(Dec), "-"),
        ],
        match issues {
          Loaded(xs) => ul(xs.map(x => li([h2(x.content), p(x.status)])))
          Pending => p("loading")
          Failed(e) => p("failed: \{e}")
        },
      ],
    ]
  })
}

///|
#cfg(target="js")
fn main {
  @rabbita.new(app).hydrate()
}

///|
#cfg(not(target="js"))
async fn main {
  let port = 3002
  let base = "http://127.0.0.1:\{port}"
  let assets = @static_file.new("./dist")
  @mocket.new()
  ..get("/issues", _ => {
    @json.to_json([
      { content: "issue 1", status: "done" },
      { content: "issue 2", status: "pending" },
      { content: "issue 3", status: "pending" },
    ])
  })
  ..get("/", _ => {
    let body = try! @rabbita.new(app).render(url=base)
    @mocket.html(body)
  })
  ..get("/assets/index.js", event => {
    event.res.headers.set("Content-Type", "text/javascript; charset=utf-8")
    assets.get_contents("index.js")
  })
  ..get("/assets/styles.css", event => {
    event.res.headers.set("Content-Type", "text/css; charset=utf-8")
    assets.get_contents("styles.css")
  })
  .listen(":\{port}")
}
