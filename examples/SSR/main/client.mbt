///|
#cfg(target="js")
fn main {
  let app = @rabbita.new(() => {
    let (count, emit) = @rabbita.create_pure_state(0, update~)
    count.map(count => view(emit(Clicked), count))
  })
  app.mount("app")
}
