---
title: Set operators
slug: set-ops
status: full
order: 70
summary: Membership, union, intersection and subset over lists treated as sets.
---

Raku has set-theoretic infixes that treat their operands as sets. Each has a Unicode
spelling (`∈`, `∪`, `∩`, `⊆`) and an ASCII equivalent written in parentheses —
`(elem)`, `(|)`, `(&)`, `(<=)`.

## Membership — `(elem)`

```raku
say 2 (elem) (1, 2, 3);
say 9 (elem) (1, 2, 3);
```
```output
True
False
```

## Union and intersection

`(|)` is union, `(&)` is intersection; both return a `Set`.

```raku
say (1, 2, 3) (|) (3, 4);
say (1, 2, 3) (&) (2, 3, 4);
```
```output
Set(1 2 3 4)
Set(2 3)
```

## Subset — `(<=)`

`(<=)` tests whether the left set is contained in the right.

```raku
say (1, 2) (<=) (1, 2, 3);
```
```output
True
```

## Notes

- Each ASCII operator mirrors a Unicode one: `(elem)`=`∈`, `(|)`=`∪`, `(&)`=`∩`,
  `(<=)`=`⊆`, plus `(-)`=`∖` for set difference.
- A `Set` deduplicates and is unordered; comparing sets (`(==)`) ignores order and
  repetition, unlike list `eqv`.
- Operands are coerced to sets, so `(1, 1, 2) (|) (2)` is `Set(1 2)` — duplicates
  collapse.
