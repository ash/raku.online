---
title: Subsets
slug: subsets
status: partial
order: 50
summary: Named types that narrow another with a `where` constraint (not yet enforced in Raku++).
---

A `subset` is a named type built from an existing one plus a `where` predicate. It
lets you attach a validity rule to a type and reuse it in signatures and
declarations.

## Declaring and using a subset

```raku
subset Even of Int where * %% 2;
my Even $n = 4;
say $n;
```
```output
4
```

`Even` is any `Int` for which `* %% 2` (divisible by two) holds. Assigning `4`
succeeds.

> **Gap:** a subset's `where` predicate is **not yet enforced** in Raku++ — assigning
> (or passing) an odd number should be a type-check failure (as in Rakudo) but is
> currently accepted. The base type (`of Int`) *is* checked; only the `where` part is
> skipped. Note this differs from a direct
> [parameter `where` constraint](/subs/constraints/), which *is* enforced.

## Notes

- `of Type` sets the base type; `where predicate` narrows it. Either part is
  optional — `subset Positive where * > 0` constrains any value.
- The `where` block receives the candidate as `$_` (here via the `*` whatever), and
  the subset matches when it returns true.
- Subsets shine in signatures: `sub f(Even $x) { … }` rejects bad arguments at the
  boundary, turning a run-time check into a dispatch-time one.
