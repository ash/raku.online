---
title: Coercion-type parameters  Int()
slug: coercion-params
status: divergent
order: 47
summary: A parameter that should coerce its argument to a type — parsed, but not yet coercing in Raku++.
---

A parameter typed `Int()` (or `Str()`, `Num()`, …) is meant to accept an argument of
**any** type that can coerce to `Int` and convert it as it binds, so the body always
sees an `Int`. Raku++ parses the syntax but **does not perform the coercion** — the
body receives the original type (see the divergence).

## The intent

```raku
sub f(Int() $x) { $x.^name }
say f("41");
say f(41.9);
```

| Call | Rakudo (reference) | Raku++ |
| ---- | ------------------ | ------ |
| `f("41").^name` | `Int` | `Str` (not coerced) |
| `f(41.9).^name` | `Int` | `Rat` (not coerced) |

Because the value isn't converted, arithmetic in the body sees the wrong type:
`sub g(Int() $x) { $x + 1 }` gives `g(41.9)` as `42.9` in Raku++ (Rat kept), but `42`
in Rakudo (`41.9` coerced to `41` first).

> Run the block to see Raku++'s result. Until this is implemented, coerce explicitly
> in the body — `my Int $n = $x.Int;` — rather than relying on the `Int()` parameter.

## Notes

- The syntax is `TargetType()` on the parameter; it should mean "accept anything, then
  call `.Type` on it". Ordinary typed parameters (`Int $x`) work normally.
- A related form is the coercion *return* type (`--> Str()`), subject to the same gap.
- Coercing explicitly with `.Int`/`.Str`/`.Num` inside the body is the reliable
  approach in Raku++ today.
