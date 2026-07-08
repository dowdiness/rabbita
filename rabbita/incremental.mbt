///|
pub using @duplix {trait Enumerate}

///|
let ambient_graph : Ref[Graph?] = Ref(None)

///|
struct Val[A](@duplix.Node[A])

///|
priv struct Graph {
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
pub fn[Model : Eq, Msg] create_simple_state(
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
pub fn[E : @duplix.Enumerate + Eq, C : Eq] Val::enumerate(
  a : Val[E],
  f : (E) -> Val[C],
) -> Val[C] {
  a.0.enumerate(e => f(e).0)
}

///|
pub fn[E : @duplix.Enumerate + Eq, C : Eq] Val::switch(
  a : Val[E],
  f : (E) -> Val[C],
) -> Val[C] {
  a.0.switch(e => f(e).0)
}

///|
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
pub fn[Model : Eq] create_single_state(
  init : Model,
) -> (Val[Model], Emit[(Model) -> Model]) {
  fn update(f, model) {
    f(model)
  }
  create_simple_state(init, update~)
}

///|
pub enum Status[T] {
  Pending
  Loaded(T)
  Failed(Error)
}

///|
pub impl[T : Eq] Eq for Status[T] with fn equal(a, b) {
  match (a, b) {
    (Pending, Pending) | (Failed(_), Failed(_)) => true
    (Loaded(a), Loaded(b)) => a == b
    _ => false
  }
}

///|
pub type Resource[T] = Val[Status[T]]

///|
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
