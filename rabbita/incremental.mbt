///|
struct Val[A](@duplix.Node[A])

///|
struct Graph {
  sandbox : @runtime.Sandbox
}

///|
fn Graph::Graph(sandbox : @runtime.Sandbox) -> Self {
  { sandbox, }
}

///|
pub fn[A : Eq, B] Val::map(a : Val[A], f : (A) -> B) -> Val[B] {
  a.0.map1(f)
}

///|
pub fn[A : Eq, B : Eq, C] Val::zip_with(
  a : Val[A],
  b : Val[B],
  f : (A, B) -> C,
) -> Val[C] {
  a.0.map2(b.0, f)
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D] Val::zip3_with(
  a : Val[A],
  b : Val[B],
  c : Val[C],
  f : (A, B, C) -> D,
) -> Val[D] {
  a.0.map3(b.0, c.0, f)
}

///|
pub fn[Model : Eq, Msg] Graph::create_simple_state(
  self : Self,
  model : Model,
  update~ : (Msg, Model) -> Model,
) -> (Val[Model], Emit[Msg]) {
  let (node, emit) = self.sandbox.create_state_machine(_ => (model, none), (
    _,
    msg,
    model,
  ) => (update(msg, model), none))
  (node, emit)
}

///|
pub fn[Model : Eq, Msg] Graph::create_state(
  graph : Graph,
  model : Model,
  update~ : (Emit[Msg], Msg, Model) -> (Model, Cmd),
  subscriptions? : (Emit[Msg], Model) -> @sub.Sub,
) -> (Val[Model], Emit[Msg]) {
  let (node, emit) = graph.sandbox.create_state_machine(
    _ => (model, none),
    update,
    subscriptions?,
  )
  (Val(node), emit)
}

///|
pub fn[K : Hash + Eq, V : Eq, C : Eq] Graph::create_assoc(
  graph : Self,
  map : Val[Map[K, V]],
  f : (Graph, K, Val[V]) -> Val[C],
) -> Val[Array[C]] {
  map.0.assoc((k, v) => f(graph, k, v).0)
}

///|
pub fn[E : @duplix.Enumerate + Eq, C : Eq] Graph::create_enum(
  _self : Self,
  map : Val[E],
  f : (E) -> Val[C],
) -> Val[C] {
  map.0.enumerate(e => f(e).0)
}

///|
pub fn[E : @duplix.Enumerate + Eq, C : Eq] Graph::create_switch(
  _graph : Self,
  map : Val[E],
  f : (E) -> Val[C],
) -> Val[C] {
  map.0.switch(e => f(e).0)
}

///|
pub fn[Model : Eq, Msg] Graph::create_state_with_init(
  graph : Graph,
  init~ : (Emit[Msg]) -> (Model, Cmd),
  update~ : (Emit[Msg], Msg, Model) -> (Model, Cmd),
  subscriptions? : (Emit[Msg], Model) -> @sub.Sub,
) -> (Val[Model], Emit[Msg]) {
  let (node, emit) = graph.sandbox.create_state_machine(
    init,
    update,
    subscriptions?,
  )
  (node, emit)
}

///|
pub fn[Model : Eq, Msg, Input : Eq] Graph::create_state_with_input(
  graph : Graph,
  init~ : (Emit[Msg], Input) -> (Model, Cmd),
  update~ : (Emit[Msg], Input, Msg, Model) -> (Model, Cmd),
  subscriptions? : (Emit[Msg], Input, Model) -> @sub.Sub,
  input~ : Val[Input],
) -> (Val[Model], Emit[Msg]) {
  let (node, emit) = graph.sandbox.create_state_machine_with_input(
    init,
    update,
    subscriptions?,
    input.0,
  )
  (node, emit)
}

///|
pub fn[Model : Eq] Graph::create_single_state(
  self : Self,
  init : Model,
) -> (Val[Model], Emit[(Model) -> Model]) {
  fn update(f, model) {
    f(model)
  }
  self.create_simple_state(init, update~)
}
