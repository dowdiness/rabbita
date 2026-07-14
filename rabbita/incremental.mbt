///|
pub using @common {trait Enumerate}

///|
#cfg(target="js")
let ambient_graph : Ref[Graph?] = Ref(None)

///|
struct Val[A](@duplix.Node[A])

///|
#cfg(target="js")
priv struct Graph {
  sandbox : @runtime.Sandbox
}

///|
#cfg(target="js")
fn Graph::Graph(sandbox : @runtime.Sandbox) -> Self {
  { sandbox, }
}

///|
pub fn[A : Eq, B] Val::map(a : Val[A], f : (A) -> B) -> Val[B] {
  a.0.map1(f)
}

///|
pub fn[A] Val::constant(a : A) -> Val[A] {
  @duplix.constant(a)
}

///|
pub fn[A : Eq, B : Eq, C] Val::map2(
  a : Val[A],
  b : Val[B],
  f : (A, B) -> C,
) -> Val[C] {
  a.0.map2(b.0, f)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D] Val::map3(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  f : (A, B, C) -> D,
) -> Val[D] {
  a.0.map3(b.0, c.0, f)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E] Val::map4(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  f : (A, B, C, D) -> E,
) -> Val[E] {
  a.0.map4(b.0, c.0, d.0, f)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F] Val::map5(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  e : Val[E],
  f : (A, B, C, D, E) -> F,
) -> Val[F] {
  a.0.map5(b.0, c.0, d.0, e.0, f)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F : Eq, G] Val::map6(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  e : Val[E],
  f : Val[F],
  g : (A, B, C, D, E, F) -> G,
) -> Val[G] {
  a.0.map6(b.0, c.0, d.0, e.0, f.0, g)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F : Eq, G : Eq, H] Val::map7(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  e : Val[E],
  f : Val[F],
  g : Val[G],
  h : (A, B, C, D, E, F, G) -> H,
) -> Val[H] {
  a.0.map7(b.0, c.0, d.0, e.0, f.0, g.0, h)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F : Eq, G : Eq, H : Eq, I] Val::map8(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  e : Val[E],
  f : Val[F],
  g : Val[G],
  h : Val[H],
  i : (A, B, C, D, E, F, G, H) -> I,
) -> Val[I] {
  a.0.map8(b.0, c.0, d.0, e.0, f.0, g.0, h.0, i)
}

///|
pub fn[
  A : Eq,
  B : Eq,
  C : Eq,
  D : Eq,
  E : Eq,
  F : Eq,
  G : Eq,
  H : Eq,
  I : Eq,
  J,
] Val::map9(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  e : Val[E],
  f : Val[F],
  g : Val[G],
  h : Val[H],
  i : Val[I],
  j : (A, B, C, D, E, F, G, H, I) -> J,
) -> Val[J] {
  a.0.map9(b.0, c.0, d.0, e.0, f.0, g.0, h.0, i.0, j)
}

///|
pub fn[A : Eq] Val::view(a : Val[A], render : (A) -> Html) -> Val[Html] {
  a.0.map(render)
}

///|
pub fn[A : Eq, B : Eq] Val::view2(
  a : Val[A],
  b : Val[B],
  render : (A, B) -> Html,
) -> Val[Html] {
  a.0.map2(b.0, render)
}

///|
pub fn[A : Eq, B : Eq, C : Eq] Val::view3(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  render : (A, B, C) -> Html,
) -> Val[Html] {
  a.0.map3(b.0, c.0, render)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq] Val::view4(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  render : (A, B, C, D) -> Html,
) -> Val[Html] {
  a.0.map4(b.0, c.0, d.0, render)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq] Val::view5(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  e : Val[E],
  render : (A, B, C, D, E) -> Html,
) -> Val[Html] {
  a.0.map5(b.0, c.0, d.0, e.0, render)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F : Eq] Val::view6(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  e : Val[E],
  f : Val[F],
  render : (A, B, C, D, E, F) -> Html,
) -> Val[Html] {
  a.0.map6(b.0, c.0, d.0, e.0, f.0, render)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F : Eq, G : Eq] Val::view7(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  e : Val[E],
  f : Val[F],
  g : Val[G],
  render : (A, B, C, D, E, F, G) -> Html,
) -> Val[Html] {
  a.0.map7(b.0, c.0, d.0, e.0, f.0, g.0, render)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F : Eq, G : Eq, H : Eq] Val::view8(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  e : Val[E],
  f : Val[F],
  g : Val[G],
  h : Val[H],
  render : (A, B, C, D, E, F, G, H) -> Html,
) -> Val[Html] {
  a.0.map8(b.0, c.0, d.0, e.0, f.0, g.0, h.0, render)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F : Eq, G : Eq, H : Eq, I : Eq] Val::view9(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  d : Val[D],
  e : Val[E],
  f : Val[F],
  g : Val[G],
  h : Val[H],
  i : Val[I],
  render : (A, B, C, D, E, F, G, H, I) -> Html,
) -> Val[Html] {
  a.0.map9(b.0, c.0, d.0, e.0, f.0, g.0, h.0, i.0, render)
}

///|
#cfg(target="js")
pub fn[Model : Eq, Msg] create_pure_state(
  model : Model,
  update~ : (Msg, Model) -> Model,
) -> (Val[Model], Emit[Msg]) {
  let graph = ambient_graph.val.unwrap()
  let (node, emit) = graph.sandbox.create_state_machine(_ => (model, none), (
    _,
    msg,
    model,
  ) => (update(msg, model), none))
  (node, emit)
}

///|
#cfg(target="js")
pub fn[Model : Eq, Msg] create_state(
  model : Model,
  update~ : (Emit[Msg], Msg, Model) -> (Model, Cmd),
  subscriptions? : (Emit[Msg], Model) -> @sub.Sub,
) -> (Val[Model], Emit[Msg]) {
  let graph = ambient_graph.val.unwrap()
  let (node, emit) = graph.sandbox.create_state_machine(
    _ => (model, none),
    update,
    subscriptions?,
  )
  (Val(node), emit)
}

///|
pub fn[K : Hash + Eq, V : Eq, C : Eq] Val::assoc(
  a : Val[Map[K, V]],
  f : (K, Val[V]) -> Val[C],
) -> Val[Array[C]] {
  a.0.assoc((k, v) => f(k, v).0)
}

///|
pub fn[E : Enumerate + Eq, C : Eq] Val::enumerate(
  a : Val[E],
  f : (E) -> Val[C],
) -> Val[C] {
  a.0.enumerate(e => f(e).0)
}

///|
pub fn[E : Enumerate + Eq, C : Eq] Val::switch(
  a : Val[E],
  f : (E) -> Val[C],
) -> Val[C] {
  a.0.switch(e => f(e).0)
}

///|
#cfg(target="js")
pub fn[Model : Eq, Msg] create_state_with_init(
  init~ : (Emit[Msg]) -> (Model, Cmd),
  update~ : (Emit[Msg], Msg, Model) -> (Model, Cmd),
  subscriptions? : (Emit[Msg], Model) -> @sub.Sub,
) -> (Val[Model], Emit[Msg]) {
  let graph = ambient_graph.val.unwrap()
  let (node, emit) = graph.sandbox.create_state_machine(
    init,
    update,
    subscriptions?,
  )
  (node, emit)
}

///|
#cfg(target="js")
pub fn[Model : Eq, Msg, Input : Eq] create_state_with_input(
  init~ : (Emit[Msg], Input) -> (Model, Cmd),
  update~ : (Emit[Msg], Input, Msg, Model) -> (Model, Cmd),
  subscriptions? : (Emit[Msg], Input, Model) -> @sub.Sub,
  input~ : Val[Input],
) -> (Val[Model], Emit[Msg]) {
  let graph = ambient_graph.val.unwrap()
  let (node, emit) = graph.sandbox.create_state_machine_with_input(
    init,
    update,
    subscriptions?,
    input.0,
  )
  (node, emit)
}

///|
#cfg(target="js")
pub fn[Model : Eq] create_variable(
  init : Model,
) -> (Val[Model], Emit[(Model) -> Model]) {
  fn update(f, model) {
    f(model)
  }
  create_pure_state(init, update~)
}

///|
#cfg(target="js")
pub enum Status[T] {
  Pending
  Loaded(T)
  Failed(Error)
}

///|
#cfg(target="js")
pub impl[T : Eq] Eq for Status[T] with fn equal(a, b) {
  match (a, b) {
    (Pending, Pending) | (Failed(_), Failed(_)) => true
    (Loaded(a), Loaded(b)) => a == b
    _ => false
  }
}

///|
#cfg(target="js")
pub type Resource[T] = Val[Status[T]]

///|
#cfg(target="js")
pub fn[T : Eq] create_resource(
  f : (Emit[Result[T, Error]]) -> Cmd,
) -> Resource[T] {
  let (status, _) : (Resource[T], _) = create_state_with_init(
    init=fn(inject) { (Pending, f(inject)) },
    update=fn(_, msg, _) {
      match msg {
        Ok(r) => (Loaded(r), none)
        Err(e) => (Failed(e), none)
      }
    },
  )
  status
}
