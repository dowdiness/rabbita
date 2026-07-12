///|
using @html {a, button, div, h1, h2, li, text, ul}

///|
using @rabbita {new, create_pure_state}

///|
enum Msg {
  Clicked
}

///|
fn main {
  fn app() {
    let (count, emit) = create_pure_state(
      0,
      update=(msg, count) => {
        match msg {
          Clicked => count + 1
        }
      },
    )
    count.map(count => {
      div(class="app") <| [
        h1(class="title", "Hello Rabbita"),
        div(class="lead", "You built it successfully!"),
        button(class="click-btn", on_click=emit(Clicked), "You clicked \{count} times"),
        div(class="next") <| [
          h2(class="next-title", "What's next"),
          ul(class="next-list") <| [
            li(
              "Edit a MoonBit file while the dev server runs for instant refresh.",
            ),
            li <| [
              text("Explore "),
              a(
                class="inline-link",
                target=Blank,
                href="https://github.com/moonbit-community/rabbita",
                "tutorials and examples",
              ),
            ],
          ],
        ],
      ]
    })
  }
  new(app).mount("app")
}
