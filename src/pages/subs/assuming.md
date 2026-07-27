---
title: Currying with .assuming
slug: assuming
status: full
order: 55
summary: Fix some of a routine's arguments to make a new, smaller routine.
---

`.assuming` **curries** a routine: it binds some arguments now and returns a new
`Callable` that takes the rest. It's partial application without writing a wrapper
closure.

## Fixing an argument

```raku
sub add($a, $b) { $a + $b }
my &add5 = &add.assuming(5);
say add5(10);
```
```output
15
```

`add5` is `add` with its first argument fixed at `5`, so `add5(10)` is `add(5, 10)`.

## Currying into a pipeline

Because the result is a plain `Callable`, a curried routine drops straight into `map`,
`grep`, or a feed — a tidy way to specialise a general routine at the call site.

```raku
sub scale($factor, $x) { $factor * $x }
my &double = &scale.assuming(2);
say (1, 2, 3).map(&double);
```
```output
(2 4 6)
```

## Notes

- `.assuming` works with named arguments too: `&f.assuming(:verbose)` fixes a named
  option while leaving the positionals open.
- The result is an ordinary `Callable`, so it composes anywhere a block or sub is
  expected — `map`, `grep`, feeds, etc.
- Currying pairs well with the [Whatever star](/operators/whatever/): `* + 5` is a
  quick one-off curry, while `.assuming` curries an existing named routine.
