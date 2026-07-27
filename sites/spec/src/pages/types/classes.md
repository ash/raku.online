---
title: Classes
slug: classes
status: full
order: 10
summary: Declare a class with attributes and methods; construct with .new.
---

A `class` bundles state (**attributes**) with behaviour (**methods**). Every class
gets a `.new` constructor that accepts named arguments for its public attributes.

## Attributes and methods

`has $.x` declares a public attribute — the `.` gives it a read accessor of the
same name. Inside a method, `$.x` calls that accessor and `$!x` reaches the
attribute directly.

```raku
class Point {
    has $.x;
    has $.y;
    method dist { sqrt($.x**2 + $.y**2) }
}
my $p = Point.new(x => 3, y => 4);
say $p.x;
say $p.dist;
```
```output
3
5
```

## Mutable state

An attribute can have a default (`= 0`) and be mutated through `$!x` inside a
method. Here `bump` increments private state:

```raku
class Counter {
    has $.count = 0;
    method bump { $!count++ }
}
my $c = Counter.new;
$c.bump;
$c.bump;
say $c.count;
```
```output
2
```

## Writable accessors

A plain `$.x` accessor is read-only from outside. Add `is rw` to let callers assign
through it.

```raku
class Box {
    has $.v is rw;
}
my $b = Box.new(v => 1);
$b.v = 99;
say $b.v;
```
```output
99
```

## Notes

- `has $!x` (bang twigil) is a *private* attribute — no accessor is generated.
- `.new` only accepts named arguments for `$.`-declared attributes; a custom
  constructor or `BUILD`/`TWEAK` submethod handles anything more involved.
- `self` is the invocant inside a method; `$.x` is shorthand for `self.x`.
