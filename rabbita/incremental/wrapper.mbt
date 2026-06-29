///|
fn[A : Eq] generic_map(
  callback : () -> A,
  subscribe : (&DynNode) -> Unit,
) -> Dyn[A] {
  let result = { value: callback(), kind: Derived(callback), subs: [] }
  subscribe(result)
  result
}

///|
#alias(zip_with)
pub fn[A, B, C : Eq] Dyn::zip_with1(
  a : Self[A],
  b : Dyn[B],
  callback : (A, B) -> C,
) -> Dyn[C] {
  generic_map(() => callback(a.value, b.value), fn(node) {
    a.subs.push(node)
    b.subs.push(node)
  })
}

///|
pub fn[A, B, C, D : Eq] Dyn::zip_with2(
  a : Self[A],
  b : Dyn[B],
  c : Dyn[C],
  callback : (A, B, C) -> D,
) -> Dyn[D] {
  generic_map(() => callback(a.value, b.value, c.value), fn(node) {
    a.subs.push(node)
    b.subs.push(node)
    c.subs.push(node)
  })
}

///|
pub fn[A, B, C, D, E : Eq] Dyn::zip_with3(
  a : Self[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  callback : (A, B, C, D) -> E,
) -> Dyn[E] {
  generic_map(() => callback(a.value, b.value, c.value, d.value), fn(node) {
    a.subs.push(node)
    b.subs.push(node)
    c.subs.push(node)
    d.subs.push(node)
  })
}

///|
pub fn[A, B, C, D, E, F : Eq] Dyn::zip_with4(
  a : Self[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  callback : (A, B, C, D, E) -> F,
) -> Dyn[F] {
  generic_map(() => callback(a.value, b.value, c.value, d.value, e.value), fn(
    node,
  ) {
    a.subs.push(node)
    b.subs.push(node)
    c.subs.push(node)
    d.subs.push(node)
    e.subs.push(node)
  })
}

///|
pub fn[A, B, C, D, E, F, G : Eq] Dyn::zip_with5(
  a : Self[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  callback : (A, B, C, D, E, F) -> G,
) -> Dyn[G] {
  generic_map(
    () => callback(a.value, b.value, c.value, d.value, e.value, f.value),
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
    },
  )
}

///|
pub fn[A, B, C, D, E, F, G, H : Eq] Dyn::zip_with6(
  a : Self[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
  callback : (A, B, C, D, E, F, G) -> H,
) -> Dyn[H] {
  generic_map(
    () => {
      callback(a.value, b.value, c.value, d.value, e.value, f.value, g.value)
    },
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
    },
  )
}

///|
pub fn[A, B, C, D, E, F, G, H, I : Eq] Dyn::zip_with7(
  a : Self[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
  h : Dyn[H],
  callback : (A, B, C, D, E, F, G, H) -> I,
) -> Dyn[I] {
  generic_map(
    () => {
      callback(
        a.value,
        b.value,
        c.value,
        d.value,
        e.value,
        f.value,
        g.value,
        h.value,
      )
    },
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
      h.subs.push(node)
    },
  )
}

///|
pub fn[A, B, C, D, E, F, G, H, I, J : Eq] Dyn::zip_with8(
  a : Self[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
  h : Dyn[H],
  i : Dyn[I],
  callback : (A, B, C, D, E, F, G, H, I) -> J,
) -> Dyn[J] {
  generic_map(
    () => {
      callback(
        a.value,
        b.value,
        c.value,
        d.value,
        e.value,
        f.value,
        g.value,
        h.value,
        i.value,
      )
    },
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
      h.subs.push(node)
      i.subs.push(node)
    },
  )
}

///|
pub fn[A, B, C, D, E, F, G, H, I, J, K : Eq] Dyn::zip_with9(
  a : Self[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
  h : Dyn[H],
  i : Dyn[I],
  j : Dyn[J],
  callback : (A, B, C, D, E, F, G, H, I, J) -> K,
) -> Dyn[K] {
  generic_map(
    () => {
      callback(
        a.value,
        b.value,
        c.value,
        d.value,
        e.value,
        f.value,
        g.value,
        h.value,
        i.value,
        j.value,
      )
    },
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
      h.subs.push(node)
      i.subs.push(node)
      j.subs.push(node)
    },
  )
}

///|
pub fn[A, B, C, D, E, F, G, H, I, J, K, L : Eq] Dyn::zip_with10(
  a : Self[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
  h : Dyn[H],
  i : Dyn[I],
  j : Dyn[J],
  k : Dyn[K],
  callback : (A, B, C, D, E, F, G, H, I, J, K) -> L,
) -> Dyn[L] {
  generic_map(
    () => {
      callback(
        a.value,
        b.value,
        c.value,
        d.value,
        e.value,
        f.value,
        g.value,
        h.value,
        i.value,
        j.value,
        k.value,
      )
    },
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
      h.subs.push(node)
      i.subs.push(node)
      j.subs.push(node)
      k.subs.push(node)
    },
  )
}

///|
pub fn[A, B, C, D, E, F, G, H, I, J, K, L, M : Eq] Dyn::zip_with11(
  a : Self[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
  h : Dyn[H],
  i : Dyn[I],
  j : Dyn[J],
  k : Dyn[K],
  l : Dyn[L],
  callback : (A, B, C, D, E, F, G, H, I, J, K, L) -> M,
) -> Dyn[M] {
  generic_map(
    () => {
      callback(
        a.value,
        b.value,
        c.value,
        d.value,
        e.value,
        f.value,
        g.value,
        h.value,
        i.value,
        j.value,
        k.value,
        l.value,
      )
    },
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
      h.subs.push(node)
      i.subs.push(node)
      j.subs.push(node)
      k.subs.push(node)
      l.subs.push(node)
    },
  )
}

///|
pub fn[A : Eq, B : Eq] zip2(a : Dyn[A], b : Dyn[B]) -> Dyn[(A, B)] {
  generic_map(() => (a.value, b.value), fn(node) {
    a.subs.push(node)
    b.subs.push(node)
  })
}

///|
pub fn[A : Eq, B : Eq, C : Eq] zip3(
  a : Dyn[A],
  b : Dyn[B],
  c : Dyn[C],
) -> Dyn[(A, B, C)] {
  generic_map(() => (a.value, b.value, c.value), fn(node) {
    a.subs.push(node)
    b.subs.push(node)
    c.subs.push(node)
  })
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq] zip4(
  a : Dyn[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
) -> Dyn[(A, B, C, D)] {
  generic_map(() => (a.value, b.value, c.value, d.value), fn(node) {
    a.subs.push(node)
    b.subs.push(node)
    c.subs.push(node)
    d.subs.push(node)
  })
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq] zip5(
  a : Dyn[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
) -> Dyn[(A, B, C, D, E)] {
  generic_map(() => (a.value, b.value, c.value, d.value, e.value), fn(node) {
    a.subs.push(node)
    b.subs.push(node)
    c.subs.push(node)
    d.subs.push(node)
    e.subs.push(node)
  })
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F : Eq] zip6(
  a : Dyn[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
) -> Dyn[(A, B, C, D, E, F)] {
  generic_map(() => (a.value, b.value, c.value, d.value, e.value, f.value), fn(
    node,
  ) {
    a.subs.push(node)
    b.subs.push(node)
    c.subs.push(node)
    d.subs.push(node)
    e.subs.push(node)
    f.subs.push(node)
  })
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F : Eq, G : Eq] zip7(
  a : Dyn[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
) -> Dyn[(A, B, C, D, E, F, G)] {
  generic_map(
    () => (a.value, b.value, c.value, d.value, e.value, f.value, g.value),
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
    },
  )
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F : Eq, G : Eq, H : Eq] zip8(
  a : Dyn[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
  h : Dyn[H],
) -> Dyn[(A, B, C, D, E, F, G, H)] {
  generic_map(
    () => {
      (a.value, b.value, c.value, d.value, e.value, f.value, g.value, h.value)
    },
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
      h.subs.push(node)
    },
  )
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq, E : Eq, F : Eq, G : Eq, H : Eq, I : Eq] zip9(
  a : Dyn[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
  h : Dyn[H],
  i : Dyn[I],
) -> Dyn[(A, B, C, D, E, F, G, H, I)] {
  generic_map(
    () => {
      (
        a.value,
        b.value,
        c.value,
        d.value,
        e.value,
        f.value,
        g.value,
        h.value,
        i.value,
      )
    },
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
      h.subs.push(node)
      i.subs.push(node)
    },
  )
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
  J : Eq,
] zip10(
  a : Dyn[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
  h : Dyn[H],
  i : Dyn[I],
  j : Dyn[J],
) -> Dyn[(A, B, C, D, E, F, G, H, I, J)] {
  generic_map(
    () => {
      (
        a.value,
        b.value,
        c.value,
        d.value,
        e.value,
        f.value,
        g.value,
        h.value,
        i.value,
        j.value,
      )
    },
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
      h.subs.push(node)
      i.subs.push(node)
      j.subs.push(node)
    },
  )
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
  J : Eq,
  K : Eq,
] zip11(
  a : Dyn[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
  h : Dyn[H],
  i : Dyn[I],
  j : Dyn[J],
  k : Dyn[K],
) -> Dyn[(A, B, C, D, E, F, G, H, I, J, K)] {
  generic_map(
    () => {
      (
        a.value,
        b.value,
        c.value,
        d.value,
        e.value,
        f.value,
        g.value,
        h.value,
        i.value,
        j.value,
        k.value,
      )
    },
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
      h.subs.push(node)
      i.subs.push(node)
      j.subs.push(node)
      k.subs.push(node)
    },
  )
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
  J : Eq,
  K : Eq,
  L : Eq,
] zip12(
  a : Dyn[A],
  b : Dyn[B],
  c : Dyn[C],
  d : Dyn[D],
  e : Dyn[E],
  f : Dyn[F],
  g : Dyn[G],
  h : Dyn[H],
  i : Dyn[I],
  j : Dyn[J],
  k : Dyn[K],
  l : Dyn[L],
) -> Dyn[(A, B, C, D, E, F, G, H, I, J, K, L)] {
  generic_map(
    () => {
      (
        a.value,
        b.value,
        c.value,
        d.value,
        e.value,
        f.value,
        g.value,
        h.value,
        i.value,
        j.value,
        k.value,
        l.value,
      )
    },
    fn(node) {
      a.subs.push(node)
      b.subs.push(node)
      c.subs.push(node)
      d.subs.push(node)
      e.subs.push(node)
      f.subs.push(node)
      g.subs.push(node)
      h.subs.push(node)
      i.subs.push(node)
      j.subs.push(node)
      k.subs.push(node)
      l.subs.push(node)
    },
  )
}
