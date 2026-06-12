///|
using @html {a, button, div, h1, h2, li, text, ul}

///|
using @rabbita {new, simple_cell}

///|
enum Msg {
  Clicked
}

///|
fn main {
  let app = simple_cell(
    model=0,
    update=(msg, count) => {
      match msg {
        Clicked => count + 1
      }
    },
    view=(emit, count) => {
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
    },
  )
  new(app).mount("app")
}
