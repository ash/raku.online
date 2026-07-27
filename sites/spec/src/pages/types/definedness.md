---
title: Definedness & type objects
slug: definedness
status: full
order: 15
summary: Every type has an undefined "type object"; .defined tells values and types apart.
---

Definedness is distinct from truth. Every type has a **type object** — an undefined
instance of the type (`Int`, `Any`, …) — and `.defined` distinguishes it from a real
value. This is what `with`/`without` and optional parameters key on.

## Values are defined, type objects are not

```raku
my $x;
say $x.defined;
say 0.defined;
say Any.defined;
```
```output
False
True
False
```

An uninitialised `$x` holds `Any` (undefined); `0` is a defined value even though it
is false; a bare type name is the undefined type object.

## Nil and type objects

```raku
say Nil.defined;
say (Int).defined;
say 42.defined;
```
```output
False
False
True
```

`Int` (the type object) is undefined; `42` (an instance) is defined.

## Notes

- Definedness ≠ truth: `0` and `""` are **defined but false**, which is exactly why
  `//` (defined-or) and `with` differ from `||` and `if` — see
  [Logical operators](/operators/logical/).
- A parameter typed `Int:D` requires a *defined* Int; `Int:U` requires the undefined
  type object — the `:D`/`:U` "definedness smileys".
- Type objects are how Raku represents "no value of this type yet", replacing null
  with something type-aware.
