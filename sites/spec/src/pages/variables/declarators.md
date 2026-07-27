---
title: Declarators — my / our / constant
slug: declarators
status: full
order: 20
summary: How a name is introduced and scoped — lexical my, package our, immutable constant.
---

A **declarator** introduces a variable and fixes its scope. `my` is the everyday
lexical declarator; `our` binds a name into the enclosing package; `constant`
defines a compile-time immutable value.

## my — lexical scope

A `my` variable is visible from its declaration to the end of the enclosing block.
An inner block can shadow an outer name.

```raku
my $x = 10;
{ my $x = 20; say $x; }
say $x;
```
```output
20
10
```

## constant

`constant` binds a name to a value once, at compile time; the value cannot be
reassigned. The sigil is optional for scalars.

```raku
constant GREETING = "hi";
say GREETING;
```
```output
hi
```

## our — package scope

`our` declares a variable in the current package, reachable from outside by its
fully-qualified `Package::name`.

```raku
our $g = 42;
say $g;
package Foo { our $bar = 99; }
say $Foo::bar;
```
```output
42
99
```

## Notes

- Prefer `my` by default; reach for `our` only when a name must be visible across
  package boundaries.
- A `constant` list is immutable. Raku++ gists a `constant @array` as `[2 3 5 7]`,
  whereas Rakudo shows the immutable-`List` form `(2 3 5 7)` — a display difference
  only; the values are identical.
- `state` is a fourth declarator — per-closure persistent storage — covered under
  [State variables](/subs/state/).
