---
title: The type tower & introspection
slug: introspection
status: full
order: 60
summary: Ask any value its type with .WHAT / .^name, and test membership with ~~.
---

Every value has a type, and every type sits in a hierarchy — the "type tower" —
rooted at `Mu`. A handful of universal methods let you ask a value what it is and
test whether it belongs to a type.

## Asking a value its type

`.WHAT` returns the value's type object (which prints in parentheses); `.^name`
returns the type's name as a string.

```raku
say 42.WHAT;
say 42.^name;
say (1, 2).WHAT;
```
```output
(Int)
Int
(List)
```

## Type membership — `~~`

Smartmatch against a type asks "is this value of that type (or a subtype)?" Because
the tower is nested, an `Int` is also `Numeric`.

```raku
say 42 ~~ Int;
say Int ~~ Numeric;
```
```output
True
True
```

`42 ~~ Int` is `True` (42 is an Int); `Int ~~ Numeric` is `True` because `Int`
*does* the `Numeric` role — membership follows the hierarchy.

## Notes

- `.WHAT` gives a **type object** — an "empty" instance of the type. `Int` and
  `42.WHAT` are the same object; comparing with `===` confirms it.
- The `.^name` method is a *metamethod* (the `.^` calls into the metaobject); the
  metaobject is also where `.^methods`, `.^attributes`, and `.^mro` live.
- Numeric types form a tower `Int` ⊂ `Rat`/`FatRat` ⊂ `Num` ⊂ `Complex`, all doing
  the `Numeric` role — see [Rational literals](/literals/rationals/) for how
  values move through it.
