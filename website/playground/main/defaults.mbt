///|
let default_mbt : String =
  #|///|
  #|using @html {a, div, h1, h2, li, text, ul}
  #|
  #|///|
  #|using @rabbita {type Cmd, type Dispatch, type Html}
  #|
  #|///|
  #|enum Msg {
  #|  Clicked
  #|}
  #|
  #|///|
  #|struct Model {
  #|  count : Int
  #|}
  #|
  #|///|
  #|fn update(msg : Msg, model : Model) -> Model {
  #|  match msg {
  #|    Clicked => { count: model.count + 1 }
  #|  }
  #|}
  #|
  #|///|
  #|fn button(value : String, on_click~ : Cmd) -> Html {
  #|  div(class="click-btn", on_click~, [text(value)])
  #|}
  #|
  #|///|
  #|fn view(dispatch : Dispatch[Msg], model : Model) -> Html {
  #|  div(class="app", [
  #|    h1(class="title", "Hello Pure MoonBit"),
  #|    div(class="lead", "The playground shell is written in MoonBit + Rabbita."),
  #|    div(class="actions", [
  #|      button(
  #|        "You clicked \{model.count} times",
  #|        on_click=dispatch(Clicked),
  #|      ),
  #|    ]),
  #|    div(class="next", [
  #|      h2(class="next-title", "What's next"),
  #|      ul(class="next-list", [
  #|        li("Edit main.mbt, index.html, or style.css."),
  #|        li([
  #|          text("Open "),
  #|          a(
  #|            class="inline-link",
  #|            target=Blank,
  #|            href="https://github.com/moonbit-community/rabbita",
  #|            "Rabbita examples",
  #|          ),
  #|        ]),
  #|      ]),
  #|    ]),
  #|  ])
  #|}
  #|
  #|///|
  #|fn main {
  #|  let app = @rabbita.simple_cell(model={ count: 0 }, update~, view~)
  #|  @rabbita.new(app).mount("app")
  #|}

///|
let default_html : String =
  #|<!doctype html>
  #|<html lang="en">
  #|  <head>
  #|    <meta charset="UTF-8" />
  #|    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  #|    <title>Playground</title>
  #|  </head>
  #|  <body>
  #|    <div id="app"></div>
  #|  </body>
  #|</html>

///|
fn html_document(title : String) -> String {
  "<!doctype html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"UTF-8\" />\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />\n    <title>" +
  title +
  "</title>\n  </head>\n  <body>\n    <div id=\"app\"></div>\n  </body>\n</html>"
}

///|
let default_moon_pkg : String =
  #|import {
  #|  "moonbit-community/rabbita",
  #|  "moonbit-community/rabbita/html",
  #|}
  #|
  #|supported_targets = "js"
  #|
  #|options(
  #|  "is-main": true,
  #|)

///|
let default_css : String =
  #|:root {
  #|  color: #111111;
  #|  background: #ffffff;
  #|  font-family:
  #|    Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI",
  #|    sans-serif;
  #|}
  #|
  #|body {
  #|  margin: 0;
  #|}
  #|
  #|.app {
  #|  min-height: 100vh;
  #|  padding: 28px 32px;
  #|  box-sizing: border-box;
  #|  background: #ffffff;
  #|}
  #|
  #|.title {
  #|  margin: 0;
  #|  color: #111111;
  #|  font-size: 40px;
  #|  line-height: 1.15;
  #|  font-weight: 800;
  #|}
  #|
  #|.lead {
  #|  margin-top: 18px;
  #|  color: #222222;
  #|  font-size: 18px;
  #|}
  #|
  #|.actions {
  #|  margin-top: 18px;
  #|  display: flex;
  #|  justify-content: flex-start;
  #|}
  #|
  #|.click-btn {
  #|  cursor: pointer;
  #|  user-select: none;
  #|  border: 1px solid #111111;
  #|  border-radius: 3px;
  #|  background: #111111;
  #|  color: #ffffff;
  #|  padding: 9px 13px;
  #|  font-weight: 700;
  #|}
  #|
  #|.click-btn:hover {
  #|  background: #333333;
  #|}
  #|
  #|.next {
  #|  margin-top: 28px;
  #|  text-align: left;
  #|}
  #|
  #|.next-title {
  #|  margin-bottom: 8px;
  #|  font-size: 18px;
  #|}
  #|
  #|.next-list {
  #|  margin: 0;
  #|  padding-left: 20px;
  #|  color: #222222;
  #|  font-size: 18px;
  #|  line-height: 1.45;
  #|}
  #|
  #|.inline-link {
  #|  color: #0066cc;
  #|}

///|
let grocery_mbt : String =
  #|///|
  #|using @html {div, h1, li, text, ul}
  #|
  #|///|
  #|fn main {
  #|  let items = [
  #|    "Black Beans",
  #|    "Limes",
  #|    "Greek Yogurt",
  #|    "Cilantro",
  #|    "Honey",
  #|    "Sweet Potatoes",
  #|    "Cumin",
  #|    "Chili Powder",
  #|    "Quinoa",
  #|  ]
  #|  let view = div(class="app", [
  #|    h1(class="title", "My Grocery List"),
  #|    ul(class="items", items.map(item => li([text(item)]))),
  #|  ])
  #|  @rabbita.new(@rabbita.static_cell(view)).mount("app")
  #|}

///|
let grocery_css : String =
  #|:root {
  #|  color: #111111;
  #|  background: #ffffff;
  #|  font-family:
  #|    Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI",
  #|    sans-serif;
  #|}
  #|
  #|body {
  #|  margin: 0;
  #|}
  #|
  #|.app {
  #|  min-height: 100vh;
  #|  padding: 28px 32px;
  #|  box-sizing: border-box;
  #|  background: #ffffff;
  #|}
  #|
  #|.title {
  #|  margin: 0 0 28px;
  #|  color: #111111;
  #|  font-size: 40px;
  #|  line-height: 1.15;
  #|  font-weight: 800;
  #|}
  #|
  #|.items {
  #|  margin: 0;
  #|  padding-left: 28px;
  #|  color: #111111;
  #|  font-size: 18px;
  #|  line-height: 1.45;
  #|}
