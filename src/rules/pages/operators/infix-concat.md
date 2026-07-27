---
title: Concatenation
sym: "~"
cat: infix
order: 10
status: written
summary: Joins two values as strings — and sits three precedence levels looser than arithmetic, which is where the surprises come from.
---

`~` glues its two operands together as strings. Like [`+`](/rules/operators/infix-plus/),
it does not require the right types; it imposes them.

## Rules

### It stringifies both operands and joins them

Each side is put in string context — `.Str` — so anything with a string form
concatenates without a cast.

```raku
say "a" ~ "b";
say 1 ~ 2;
```
```output
ab
12
```

`1 ~ 2` is `"12"`, not `3`. The operator decides the context, not the operands.

### A list stringifies to its elements joined with a space

This is `.Str` on a list, not a rule of `~`. It is why building a message out of a
list rarely gives what you meant.

```raku
say (1, 2) ~ "x";
```
```output
1 2x
```

### It is at *concatenation*, looser than arithmetic and replication

The chips above place `~` at `concatenation 10/27`. Multiplicative (7), additive
(8) and replication (9) are all tighter, so arithmetic on either side happens
first and you very rarely need parentheses around it.

```raku
say "n=" ~ 1 + 2;
say "x" x 2 ~ "y";
```
```output
n=3
xxy
```

Both read the way you want: `"n=" ~ (1 + 2)` and `("x" x 2) ~ "y"`. That ordering is
deliberate — concatenation is the operator you almost always want to apply last.

### `~=` appends in place

```raku
my $s = "a";
$s ~= "b";
say $s;
```
```output
ab
```

### It metaoperates like any other infix

`[~]` reduces a list with it, `Z~` zips pairwise, `X~` crosses.

```raku
say [~] <a b c>;
say ("a", "b") Z~ ("1", "2");
```
```output
abc
(a1 b2)
```

## Traps

### `~` is three different operators depending on position

The same character is an infix here, a prefix elsewhere, and part of several
compound spellings. They are unrelated in meaning and in precedence.

| Spelling | Category | Meaning |
|---|---|---|
| `$a ~ $b` | infix, concatenation (10) | concatenate |
| `~$a` | prefix, symbolic unary (5) | coerce to `Str` |
| `$a ~~ $b` | infix, chaining (15) | smartmatch |
| `$a ~& $b`, `~\|`, `~^` | infix | string bitwise ops |

`~$a` is the idiomatic stringification, and being at symbolic-unary precedence it
binds tighter than everything except method calls and `**`.

```raku
my @a = 1, 2, 3;
say ~@a;
say (~@a).WHAT;
```
```output
1 2 3
(Str)
```

### An undefined operand is a warning in Rakudo and an error in Raku++

Rakudo warns *Use of Nil in string context* (or *uninitialized value*) and treats the
operand as the empty string. Raku++ diverges, and not gracefully:

```diverge
say Nil ~ "x";
```
```text
Rakudo:  warns, then prints  x
Raku++:  No such method 'Nil' for invocant of type 'Str'
```

`"a" ~ Any` is the same story: Rakudo warns and prints `a`, Raku++ prints `a`
silently. Either way, an undefined value reaching `~` means a missing `//` default
somewhere upstream.

### Concatenating in a loop is quadratic

`$s ~= …` builds a new string each time. For anything longer than a few hundred
appends, push onto an array and `.join` once.

```raku
my @parts;
@parts.push("x$_") for ^5;
say @parts.join(",");
```
```output
x0,x1,x2,x3,x4
```

## See also

- [`prefix:<~>`](/rules/operators/prefix-concat/) — coercion to `Str`
- [`infix:<x>`](/rules/operators/infix-x/) — string replication, one level tighter
- [`infix:<+>`](/rules/operators/infix-plus/) — the numeric counterpart, three levels tighter
