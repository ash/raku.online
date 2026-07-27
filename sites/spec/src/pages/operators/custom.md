---
title: Custom operators
slug: custom
status: full
order: 96
summary: Define your own prefix, infix, and postfix operators as ordinary subs.
---

Operators in Raku are just subs with special names. Declaring `sub infix:<…>`,
`prefix:<…>`, or `postfix:<…>` adds a new operator to the language — usable with the
same syntax as the built-ins, Unicode symbols included.

## A postfix operator

The name `postfix:<!>` defines `!` after its operand — here, factorial.

```raku
sub postfix:<!>($n) { [*] 1..$n }
say 5!;
```
```output
120
```

## An infix operator

```raku
sub infix:<×>($a, $b) { $a * $b }
say 6 × 7;
```
```output
42
```

## A prefix operator

```raku
sub prefix:<√>($x) { $x.sqrt }
say √16;
```
```output
4
```

## Notes

- The three slots are `prefix` (before), `postfix` (after), and `infix` (between);
  there is also `circumfix` (like `⟨ ⟩`) and `postcircumfix` (like `[ ]`).
- Operator names can be any symbol run, ASCII or Unicode, so `×`, `√`, and `∘` are
  all valid.
- Give a custom infix a precedence with a trait — `is tighter(&infix:<+>)`,
  `is looser(...)`, or `is equiv(...)` — otherwise it defaults to the tightest.
