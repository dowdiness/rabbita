using @rabbita { new, static_cell }
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

  let app = static_cell(html)
  new(app).mount("app")
}
