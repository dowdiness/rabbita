using @rabbita { new, create_variable }
using @html {div, h1, li, ul}

fn main {
  let items = [
    "Black Beans", "Limes", "Greek Yogurt", "Cilantro", "Honey", "Sweet Potatoes",
    "Cumin", "Chili Powder", "Quinoa",
  ]

  let html = div(class="app") <| [
    h1(class="title", "My Grocery List"),
    ul(class="items", [for item in items => li(item)]),
  ]

  fn app() {
    let (page, _) = create_variable(html)
    page
  }
  new(app).mount("app")
}
