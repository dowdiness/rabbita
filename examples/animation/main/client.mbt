///|
using @html {div, h1}

///|
using @rabbita {type Cmd, type Emit, type Html}

///|
enum Msg {
  SelectPattern(Int)
  AnimationFrameTick(Double)
}

///|
struct Model {
  frame_count : Int
  last_frame_ms : Double
  logo : LogoModel
  logo_pattern_index : Int
}

///|
fn update(_ : Emit[Msg], msg : Msg, model : Model) -> (Cmd, Model) {
  match msg {
    SelectPattern(index) => (@rabbita.none, set_animation_pattern(index, model))
    AnimationFrameTick(timestamp) =>
      (@rabbita.none, step_animation_frame(timestamp, model))
  }
}

///|
fn subscriptions(emit : Emit[Msg], _ : Model) -> @sub.Sub {
  @sub.on_animation_frame(emit.map(timestamp => AnimationFrameTick(timestamp)))
}

///|
fn view(emit : Emit[Msg], model : Model) -> Html {
  div(class="page") <| [
    h1(class="title", "Rabbita Animation"),
    div(class="stage") <| [
      logo_view(model.logo),
    ],
    div(class="actions") <| animation_actions(emit, model),
  ]
}

///|
#cfg(target="js")
fn main {
  let initial_model = reset_animation({
    frame_count: 0,
    last_frame_ms: 0.0,
    logo: logo_start(),
    logo_pattern_index: 0,
  })
  let app = @rabbita.cell(model=initial_model, update~, view~, subscriptions~)
  @rabbita.new(app).mount("app")
}
