---
title: The ternary operator  ?? !!
slug: ternary
status: full
order: 10
summary: Choose between two expressions on a condition — Raku's if-expression.
---

The ternary conditional operator evaluates a condition and returns one of two
expressions. It is written with `??` and `!!` rather than the `?` and `:` of the
C family, because `?` and `:` are needed elsewhere in Raku.

## Syntax

```syntax
CONDITION ?? THEN-EXPR !! ELSE-EXPR
```

The condition is evaluated in Boolean context. If it is true, the whole expression
is `THEN-EXPR`; otherwise it is `ELSE-EXPR`. Only the chosen branch is evaluated.

```raku
say 5 > 3 ?? "yes" !! "no";
```
```output
yes
```

## It is an expression

Unlike a statement `if`, the ternary *produces a value*, so it can sit anywhere an
expression can — inside a larger expression, an argument list, or an assignment.

```raku
my $age = 20;
my $fare = $age < 18 ?? 0 !! 5;
say "Fare: $fare";
```
```output
Fare: 5
```

## Chaining

Because the else-branch is itself an expression, ternaries chain to express a
multi-way choice. It reads left to right as a sequence of "otherwise, if…".

```raku
my $n = -4;
say $n < 0 ?? "neg" !! $n == 0 ?? "zero" !! "pos";
```
```output
neg
```

## Whitespace is required

Both `??` and `!!` must be surrounded by whitespace. This is what lets Raku keep
`?` and `!` free for other roles (such as the `?` and `!` method-call twigils and
Boolean coercion) without ambiguity.

> Writing `5>3??"y"!!"n"` is a parse error, not a tight-packed ternary. Always
> space the operators: `5 > 3 ?? "y" !! "n"`.

## Notes

- Precedence sits just above assignment, so `$x = $c ?? $a !! $b` parses as
  `$x = ($c ?? $a !! $b)`, as you would want.
- For choosing between statements (rather than values), use a statement `if`/`else`
  block instead.
