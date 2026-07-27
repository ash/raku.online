---
title: where constraints
slug: constraints
status: full
order: 35
summary: Narrow a parameter with a predicate — a value must be the right type and satisfy the test.
---

A `where` clause attaches a predicate to a parameter, so a value must both be of the
right type **and** satisfy the test. An argument that fails the predicate is rejected,
so the routine never runs with a bad value.

## A constrained parameter

```raku
sub f(Int $n where * > 0) {
    $n * 2;
}
say f(5);
```
```output
10
```

The predicate can be any expression — `where *.chars > 3`, `where * %% 2`, or a
literal value.

```raku
sub g($s where *.chars > 3) {
    "ok: $s";
}
say g("hello");
```
```output
ok: hello
```

## A failing argument is rejected

An argument that fails the predicate causes the call to fail — no candidate matches —
so `try` catches it and the fallback runs.

```raku
sub pos(Int $n where * > 0) { $n }
say (try pos(-1)) // "rejected";
```
```output
rejected
```

`pos(-1)` fails the `* > 0` check, so the value never reaches the body.

## Notes

- `where` is also how `subset` types narrow a base type — see
  [Subsets](/types/subsets/).
- For dispatch, a `where` on a [multi](/subs/multi/) candidate is how you route
  on a value (e.g. a `0` case vs the general case).
- A passing constraint has zero runtime cost beyond evaluating the predicate once per
  call.
