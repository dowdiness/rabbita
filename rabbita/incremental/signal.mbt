///|
priv enum Kind[A] {
  Input
  Derived(() -> A)
}

///|
struct Dyn[A] {
  mut value : A
  kind : Kind[A]
  subs : Array[&DynNode]
}

///|
priv struct AssocEntry[V, C] {
  value : Input[V]
  result : Dyn[C]
  mut epoch : Int
}

///|
pub fn[K : Hash + Eq, V : Eq, C : Eq] Dyn::assoc(
  a : Dyn[Map[K, V]],
  f : (K, Dyn[V]) -> Dyn[C],
) -> Dyn[Array[C]] {
  let mut entries : Map[K, AssocEntry[V, C]] = Map([])
  let mut epoch = 0
  let mut recomputing = false
  let mut output : Dyn[Array[C]]? = None
  let child_observer = Observer(() => {
    if !recomputing {
      if output is Some(output) {
        output.recompute()
      }
    }
  })
  fn compute() {
    recomputing = true
    epoch += 1
    for k, v in a.value {
      if entries.get(k) is Some(entry) {
        if entry.value.get() != v {
          entry.value.set(v)
        }
        entry.epoch = epoch
      } else {
        let value = input(v)
        let result = f(k, value.to_dyn())
        result.subs.push(child_observer)
        let entry = { value, result, epoch }
        entries.set(k, entry)
      }
    }

    entries = Map([ for k, e in entries if e.epoch == epoch => (k, e) ])

    let result = [ for _, e in entries => e.result.value ]
    recomputing = false
    result
  }
  let node = { value: compute(), kind: Derived(() => compute()), subs: [] }
  output = Some(node)
  a.subs.push(node)
  node
}

///|
priv struct Observer(() -> Unit)

///|
impl DynNode for Observer with fn recompute(f) {
  f()
}

///|
impl[A : Eq] DynNode for Dyn[A] with fn recompute(a) {
  match a.kind {
    Input =>
      for x in a.subs {
        x.recompute()
      }
    Derived(f) => {
      let old = a.value
      let new = f()
      a.value = new
      if old != new {
        for x in a.subs {
          x.recompute()
        }
      }
    }
  }
}

///|
fn[A] Dyn::Dyn(a : A) -> Dyn[A] {
  { value: a, kind: Input, subs: [] }
}

///|
pub fn[A, B : Eq] Dyn::map(a : Self[A], callback : (A) -> B) -> Dyn[B] {
  let b = {
    value: callback(a.value),
    kind: Derived(() => callback(a.value)),
    subs: [],
  }
  a.subs.push(b)
  b
}

///|
priv trait DynNode {
  fn recompute(Self) -> Unit
}

///|
struct Input[A](Dyn[A])

///|
pub fn[A] input(a : A) -> Input[A] {
  Dyn(a)
}

///|
pub fn[A : Eq] Input::set(a : Input[A], v : A) -> Unit {
  guard a.kind is Input
  a.value = v
  a.0.recompute()
}

///|
pub fn[A] Input::get(a : Input[A]) -> A {
  a.0.value
}

///|
pub fn[A] Input::to_dyn(self : Self[A]) -> Dyn[A] {
  self.0
}

///|
test {
  let input1 = input(10)
  let input2 = input(false)
  let a = input1.to_dyn()
  let b = input2.to_dyn()
  let c = a.map(x => x * 20)
  let d = b.zip_with1(c, (b, c) => "\{b}, \{c}")
  debug_inspect(
    d.value,
    content=(
      #|"false, 200"
    ),
  )
  input2.set(true)
  debug_inspect(
    d.value,
    content=(
      #|"true, 200"
    ),
  )
}

///|
test "assoc propagates child dyn changes" {
  let source = input(Map([(0, 10)]))
  let child = input(false)
  let associated = source
    .to_dyn()
    .assoc(fn(_, value) {
      child
      .to_dyn()
      .zip_with(value, (enabled, value) => {
        if enabled {
          value + 1
        } else {
          value
        }
      })
    })
  assert_eq(associated.value.length(), 1)
  assert_eq(associated.value[0], 10)
  child.set(true)
  assert_eq(associated.value.length(), 1)
  assert_eq(associated.value[0], 11)
  source.set(Map([(0, 20)]))
  assert_eq(associated.value.length(), 1)
  assert_eq(associated.value[0], 21)
}

///|
pub fn[A] read(_ : @key.Key, a : Dyn[A]) -> A {
  a.value
}

///|
pub fn[C : Eq] sequence(xs : Array[Dyn[C]]) -> Dyn[Array[C]] {
  generic_map(
    () => {
      let arr = []
      for x in xs {
        arr.push(x.value)
      }
      arr
    },
    fn(node) {
      for x in xs {
        x.subs.push(node)
      }
    },
  )
}
