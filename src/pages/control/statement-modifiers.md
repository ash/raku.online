---
title: Statement modifiers
slug: statement-modifiers
status: full
order: 15
summary: Postfix if / unless / for / while — a whole control structure after the statement.
---

A **statement modifier** attaches a condition or loop to the *end* of a single
statement — no block, no braces. It reads like English and is the idiomatic form for
one-liners.

## Postfix if / unless

```raku
say "even" if 4 %% 2;
say "odd" unless 4 %% 2;
```
```output
even
```

The `unless` line produces nothing because `4 %% 2` is true.

## Postfix for

A trailing `for` runs the statement once per element, with `$_` set — so the
`.method` shorthand pairs naturally with it.

```raku
say $_ for 1..3;
.say for <a b>;
```
```output
1
2
3
a
b
```

## Postfix while / until

```raku
my $i = 0;
$i++ while $i < 3;
say $i;
```
```output
3
```

## Notes

- Modifiers don't nest and take no `else` — reach for the block forms
  ([if / unless / with](/control/conditionals/),
  [loops](/control/loops/)) when you need more than one clause.
- The postfix `for` topicalises `$_`, exactly like the block `for`, so
  `.say for @items` is the compact "print each" idiom.
- Precedence is loose, so the whole statement to the left is the body:
  `say $_ * 2 for 1..3` doubles each element.
