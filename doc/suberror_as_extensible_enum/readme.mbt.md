# Suberror as Extensible Enum

In MoonBit, enum types are closed-world, meaning all constructors (also called 
variants) of an enum must be defined within the same package. This enables the 
compiler to perform exhaustive pattern matching checks, which is helpful for refactoring.

This design also introduces a limitation: enum types cannot be extended across 
packages. It becomes particularly restrictive when building libraries that need 
to support user-defined extensions or custom behaviors.

Some languages support open-world enums, often referred to as extensible enums 
(or extensible variants). While MoonBit does not yet provide native support for 
extensible enums, the Error type effectively serves this purpose, as it is extensible.

## Use suberror to in Plugin System

```mbt check
// in package 1

///|
suberror UserPlugin1 {
  UserConstructor1(Int, String)
}

// in package 2

///|
suberror UserPlugin2 {
  UserConstructor2(Int)
}

///|
fn consume(x : Error) -> Unit raise {
  match x {
    UserConstructor1(x, y) => {
      assert_eq(x, 42)
      assert_eq(y, "hello")
    }
    UserConstructor2(x) => assert_eq(x, 42)
    _ => fail("should match UserConstructor")
  }
}

///|
test {
  let a : UserPlugin1 = UserConstructor1(42, "hello")
  let b : UserPlugin2 = UserConstructor2(42)
  consume(a)
  consume(b)
}
```

We can define custom suberror types such as `UserPlugin1` and `UserPlugin2`, and use 
them as values of type `Error`. When matching on `Error`, if the corresponding suberror 
types and their constructors are in scope, the pattern match can safely downcast 
and match against those constructors.

In this way, `Error` behaves like an extensible enum, allowing different packages 
to contribute new variants while still supporting pattern matching where applicable.

# Why Not Trait Objects

Trait objects are a common approach for enabling extensibility in API design. 
They don’t always work well because of object safety constraints. This limitation 
has influenced the internal API design of subscriptions in Rabbita. You can read 
more about this [here](https://github.com/moonbit-community/rabbita/blob/main/rabbita/sub/design.md).
