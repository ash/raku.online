---
title: Universal methods
slug: universal
status: full
order: 5
summary: Methods every value has — .raku, .clone, .Bool, and callable arity.
---

A handful of methods come from the root type `Mu`, so *every* value has them:
`.raku` for a code representation, `.clone` for a copy, `.Bool` for truthiness, and
introspection like `.arity` on callables.

## .raku — code representation

`.raku` returns a string of Raku code that would reconstruct the value — the exact,
unrounded view (as opposed to the human `.gist` that `say` uses).

```raku
say [1, 2, 3].raku;
say (a => 1).raku;
say "hi".raku;
```
```output
[1, 2, 3]
:a(1)
"hi"
```

## .clone — a shallow copy

`.clone` copies an object, optionally overriding attributes. The copy is independent.

```raku
class P { has $.x is rw }
my $p = P.new(x => 1);
my $q = $p.clone;
$q.x = 2;
say $p.x;
say $q.x;
```
```output
1
2
```

## .Bool — truthiness

Every value defines `.Bool`; empty collections are false.

```raku
say [1, 2, 3].Bool;
say [].Bool;
say {}.Bool;
```
```output
True
False
False
```

## Callable introspection — arity & count

A sub or block reports its required parameter count (`.arity`) and its maximum
(`.count`, including optionals).

```raku
sub f($x, $y, $z?) {}
say &f.arity;
say &f.count;
```
```output
2
3
```

## Notes

- `.raku` round-trips: `EVAL $value.raku` reproduces the value — handy for
  debugging exact structure and type.
- `.gist` is the human-readable form `say`/`put` use; `.Str` is the plain string
  coercion. All three come from `Mu`.
- `.WHAT` (type object) and `.defined` are also universal — see
  [The type tower](/types/introspection/) and
  [Definedness](/types/definedness/).
