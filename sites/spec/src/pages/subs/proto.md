---
title: proto
slug: proto
status: full
order: 45
summary: A shared front-end for a family of multi candidates.
---

A `proto` declares the common shape of a `multi` family — one place to name the
routine and, optionally, run shared code around every candidate. The body `{*}`
means "dispatch to the best matching multi".

## Declaring a proto

```raku
proto describe(|) {*}
multi describe(Int $) { "int" }
multi describe(Str $) { "str" }
say describe(5);
say describe("x");
```
```output
int
str
```

The `proto`'s signature `(|)` accepts any arguments (a capture); each `multi`
narrows it, and `{*}` hands off to the one that fits.

## Notes

- A `proto` is optional — a bare set of `multi`s works — but it documents the family
  and gives the routine one signature (`(|)` here) that every candidate narrows.
- The `proto` fixes the routine's name and shared signature; individual candidates
  fill in the behaviour — see [Multi dispatch](/subs/multi/).
- In Rakudo the `{*}` may be surrounded by code that runs once before dispatch (to
  validate or transform arguments); **Raku++ treats the `proto` as dispatch-only** and
  does not run that surrounding code, so keep such logic inside the candidates.
