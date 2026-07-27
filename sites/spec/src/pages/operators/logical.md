---
title: Logical operators
slug: logical
status: full
order: 44
summary: Short-circuiting and / or / not, defined-or //, and their low-precedence words.
---

Raku's logical operators short-circuit and, crucially, **return one of their
operands** rather than a plain `Bool` — so they double as value-selectors. There are
tight symbolic forms and loose word forms.

## and, or, not

`&&` is logical-and, `||` logical-or, `!` negation. In Boolean context they behave as
expected.

```raku
say True && False;
say True || False;
say !True;
```
```output
False
True
False
```

## They return an operand

`||` returns the first true operand (or the last), `&&` the first false one (or the
last) — the basis of the "or a default" idiom.

```raku
say 0 || "default";
say "" || "fallback";
say 42 && "reached";
```
```output
default
fallback
reached
```

## Defined-or — `//`

`//` returns its left side unless it is **undefined**, in which case the right. Unlike
`||`, a defined-but-false value (like `0`) passes through.

```raku
say Any // "fallback";
say 5 // 10;
```
```output
fallback
5
```

## Low-precedence words

`and`, `or`, `not` are the same operations at very loose precedence — handy for
control flow (`open($f) or die`) without parentheses.

```raku
say (1 and 2);
say (0 or 3);
say (not 0);
```
```output
2
3
True
```

## Notes

- Because `//` keys on definedness, use it for "default when missing" and `||` for
  "default when falsy" — `0 // 9` is `0`, but `0 || 9` is `9`.
- The word forms sit *below* assignment in precedence, so `$x = $a or $b` parses as
  `($x = $a) or $b` — a classic gotcha; use `||` when you mean the value.
- Each has an assignment metaform: `||=`, `&&=`, `//=` (assign only if the current
  value is false / true / undefined).
