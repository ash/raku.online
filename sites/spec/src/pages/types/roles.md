---
title: Roles
slug: roles
status: full
order: 30
summary: Reusable bundles of behaviour composed into classes with `does`.
---

A `role` packages methods (and attributes) for reuse. A class **composes** a role
with `does`, flattening the role's members into the class. Roles are Raku's
preferred alternative to deep inheritance for sharing behaviour.

## Composing a role

```raku
role Greet {
    method hello { "Hi, I am " ~ self.name }
}
class Person does Greet {
    has $.name;
}
say Person.new(name => "Ada").hello;
```
```output
Hi, I am Ada
```

The role's `hello` becomes a method of `Person`, and `self.name` resolves against
the composing class's attribute.

## Required methods — an interface

A role can *require* a method by leaving its body as a stub (`{ ... }`). The role's own
methods may call it, and the composing class supplies the implementation — an
interface contract.

```raku
role Speaker {
    method speak { ... }                      # required
    method announce { "It says: " ~ self.speak }
}
class Dog does Speaker {
    method speak { "woof" }
}
say Dog.new.announce;
```
```output
It says: woof
```

## Composing several roles

A class can compose any number of roles; their methods all flatten in together.

```raku
role Walks { method move { "walk" } }
role Swims { method swim { "swim" } }
class Duck does Walks does Swims { }
say Duck.new.move ~ " and " ~ Duck.new.swim;
```
```output
walk and swim
```

## Parameterized roles

A role can take a type parameter in `[…]`, so one role generates a family of typed
behaviours.

```raku
role Container[::T] {
    has T @.items;
    method count { @.items.elems }
}
class IntBox does Container[Int] { }
say IntBox.new(items => [1, 2, 3]).count;
```
```output
3
```

## Notes

- Composition is flattening, not delegation: a method conflict between two composed
  roles is a conflict you resolve explicitly — unlike the silent shadowing of multiple
  inheritance.
- A required method (the `{ ... }` stub) documents the interface a consumer must
  satisfy; provide it in the composing class as shown above.
- Roles can also be applied to a single object at runtime with `$obj does SomeRole` —
  see [Runtime mixins](/types/role-mixin/).
- A role used where a class is expected (`my Speaker $x`) acts as a type constraint,
  so roles double as interfaces for typing.
