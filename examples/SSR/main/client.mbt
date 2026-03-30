///|
#cfg(target="js")
fn main {
  let app = @rabbita.simple_cell(model=0, update~, view~)
  @rabbita.new(app).mount("app")
}
