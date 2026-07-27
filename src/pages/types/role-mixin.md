---
title: Runtime mixins & role requirements
slug: role-mixin
status: full
order: 35
summary: Add a role to a single object at runtime with `but`, and require methods with a stub.
---

Beyond composing roles into a class ([Roles](/types/roles/)), a role can be mixed
into **one object** at runtime, and a role can **require** the composing class to
supply a method.

## Required methods

A method body of `{ ... }` (the "stub", yada-yada) declares a method the composing
class *must* provide — an interface contract.

```raku
role R { method needed { ... } }
class C does R { method needed { "done" } }
say C.new.needed;
```
```output
done
```

## Runtime mixin with `but`

`$value but Role` produces a new object that has the role's methods, without changing
the original type — the value still behaves as itself otherwise.

```raku
role Barks { method speak { "Woof" } }
my $x = 42 but Barks;
say $x.speak;
say $x + 1;
```
```output
Woof
43
```

`$x` gained `.speak` yet is still an `Int` for arithmetic (`$x + 1` is `43`).

## Notes

- `but` returns a new object; `does` (as an infix, `$obj does Role`) mixes the role
  into an existing mutable container in place.
- A class that composes a role with an unimplemented required method fails to compose
  — the contract is checked at compile time.
- Runtime mixins are handy for tagging one value with extra behaviour (a role that
  adds logging, say) without subclassing.
