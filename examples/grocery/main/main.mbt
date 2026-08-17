using @rabbita { type Val, new }
using @html { type Html, div, h1, li, ul}

fn app() -> Val[Html] {
  let items = [
    "Black Beans", "Limes", "Greek Yogurt", "Cilantro", "Honey", "Sweet Potatoes",
    "Cumin", "Chili Powder", "Quinoa",
  ]

  let html = div(class="app") <| [
    h1(class="title", "My Grocery List"),
    ul(class="items", [for item in items => li(item)]),
  ]

  Val::constant(html)
}

fn main {
  new(app).mount("app")
}
