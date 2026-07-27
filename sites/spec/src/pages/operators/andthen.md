---
title: andthen & orelse
slug: andthen
status: full
order: 46
summary: Chain on definedness — continue if defined (andthen) or if undefined (orelse).
---

`andthen` and `orelse` sequence expressions by **definedness**, passing the left
result along as the topic `$_`. `andthen` continues when the left is defined;
`orelse` continues when it is undefined — the flow-control cousins of `//`.

## andthen — continue if defined

If the left side is defined, `andthen` evaluates the right with `$_` set to it;
otherwise it short-circuits to the undefined value.

```raku
say (5 andthen $_ * 2);
say (Nil andthen "unreached") // "skipped";
```
```output
10
skipped
```

`5` is defined, so `$_ * 2` runs (`10`); `Nil` is undefined, so the `andthen`
short-circuits and `//` supplies `skipped`.

## orelse — continue if undefined

`orelse` is the mirror: it runs the right side only when the left is **undefined**.

```raku
say (Nil orelse "fallback");
say (5 orelse "unused");
```
```output
fallback
5
```

## Notes

- `orelse` is like `//` but binds `$_` to the (undefined) left value, so the
  right-hand side can inspect *why* — useful with a `Failure` on the left.
- `andthen` chains "do this, then with its result do that", stopping at the first
  undefined step — a tidy pipeline for maybe-values.
- Both key on **definedness**, not truth, so a defined-but-false `0` flows through
  `andthen` (unlike `&&`).
