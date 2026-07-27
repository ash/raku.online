---
title: Addition
sym: +
cat: infix
order: 10
status: written
summary: Numeric addition — and, because it imposes numeric context, a coercion operator in disguise.
---

`+` adds two numbers. Almost everything surprising about it comes from the second
half of that sentence: it does not *require* numbers, it **makes** them, and what it
makes depends on the type of each operand.

## Rules

### It adds its two operands numerically

```raku
say 2 + 3;
say -1 + 1;
```
```output
5
0
```

### Both operands are put in numeric context first

`+` never concatenates and never checks that you meant a number. Each side is
coerced by calling `.Numeric` on it, so anything with a numeric interpretation
participates.

```raku
say "6" + "3";
say True + True;
```
```output
9
2
```

### A list operand numifies to its element count

This is not a special case in `+`; it is what `.Numeric` on a list means. It is the
single most common way to be surprised by this operator.

```raku
say (1, 2) + (3, 4, 5);
say [10, 20, 30] + 1;
```
```output
5
4
```

`(1, 2)` becomes `2` and `(3, 4, 5)` becomes `3`. If you wanted to add the contents,
you wanted `[+]` — the reduction metaoperator — or `Z+` to add pairwise.

```raku
say [+] 1, 2, 3, 4;
say (1, 2, 3) Z+ (10, 20, 30);
```
```output
10
(11 22 33)
```

### The result type is the widest of the operand types

Raku's numeric tower promotes rather than truncates. `Int + Int` stays `Int`,
`Rat + Rat` stays `Rat` — exactly, with no binary-floating-point error — and a
`Complex` anywhere makes the result `Complex`.

```raku
say (1/3 + 1/6).WHAT;
say 1/3 + 1/6;
say (1 + 2i).WHAT;
```
```output
(Rat)
0.5
(Complex)
```

`0.1 + 0.2` is exactly `0.3` here, because both literals are `Rat`, not `Num`. That
is a property of the *literals*, not of `+`: write `0.1e0 + 0.2e0` and you get the
floating-point answer instead.

```raku
say 0.1 + 0.2 == 0.3;
say 0.1e0 + 0.2e0 == 0.3e0;
```
```output
True
False
```

### Int arithmetic does not overflow

`Int` is arbitrary-precision. Passing 64 bits is not an event.

```raku
say 2**64 + 1;
```
```output
18446744073709551617
```

### It is left-associative and additive-precedence

The chips above say `additive 8/27` and `left-assoc`, which fixes two things at
once: `a + b + c` groups as `(a + b) + c`, and `+` binds tighter than every level
below the eighth — including `x`, `xx`, `~`, and the comparisons.

```raku
say 1 + 2 ~ 3 + 4;
```
```output
37
```

That is `(1 + 2) ~ (3 + 4)`, not `1 + (2 ~ 3) + 4`. Concatenation sits at 10, two
levels looser than additive.

## Traps

### `x` is looser than `+`, which reads backwards

Replication (level 9) is looser than additive (level 8), so the arithmetic on the
right of `x` happens first.

```raku
say "-" x 3 + 2;
```
```output
-----
```

Five dashes, not `"---" + 2`. If you meant the other grouping, parenthesise it.

### Unary `+` is a different operator with much tighter precedence

`+$x` is `prefix:<+>` — a coercion to `Numeric` at *symbolic unary* precedence
(level 5), far tighter than the infix at 8. It is the idiomatic way to force a
string to a number, and it accepts every literal form Raku does.

```raku
say +"0x1f";
say +"1_000";
say +"3/4";
```
```output
31
1000
0.75
```

### A `Nil` operand contributes zero, with a warning on Rakudo

Rakudo warns *Use of Nil in numeric context* and continues with `0`. Raku++ produces
the same value but does not currently emit the warning.

```raku
say Nil + 1;
```
```output
1
```

## Errors

### A string that is not fully numeric throws

Numeric context is not a best-effort parse. A string with trailing junk is an
error, not a silent `3`:

```bad
say "3abc" + 1;
```

```text
Rakudo:  Cannot convert string to number: trailing characters after number in '3<HERE>abc' (indicated by <HERE>)
Raku++:  Cannot convert string to number: trailing characters after number in '3abc'
```

Both engines refuse it. The only difference left is cosmetic: Rakudo marks the
offending position with `<HERE>`, Raku++ does not.

> This page previously recorded that Raku++ returned `4` here instead of
> throwing. That was true when the page was written and has since been fixed —
> which is worth knowing about the pages generally: a hand-written claim about a
> divergence is a snapshot, and only the *examples* are re-verified on every
> build.

## See also

- [`prefix:<+>`](/rules/operators/prefix-plus/) — the coercion operator
- [`infix:<~>`](/rules/operators/infix-concat/) — concatenation, two precedence levels looser
- [`infix:<->`](/rules/operators/infix-minus/) — same level, same associativity
