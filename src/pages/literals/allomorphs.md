---
title: Allomorphs — IntStr, RatStr & friends
slug: allomorphs
status: full
order: 45
summary: Angle-bracket literals that are a number and a string at the same time.
---

A value written inside angle brackets — `<42>`, `<1.5>` — is an **allomorph**: it is
*both* a number and the string you typed, at once. The `<…>` quoting word recognises
a numeric word and gives back a dual-typed value (`IntStr`, `RatStr`, `NumStr`,
`ComplexStr`) that behaves as the number in numeric context and as the string in
string context. This is the type you get from user input parsed with `<…>`, from
`.words` over numeric text, and from command-line arguments.

## A number and a string at once

`<42>` is an `IntStr`. It compares equal to the `Int` `42` *and* to the string
`"42"`, and it carries string methods like `.flip`.

```raku
my $n = <42>;
say $n.^name;
say $n + 8;
say $n.flip;
```
```output
IntStr
50
24
```

The type name `IntStr` says it all: it does the `Int` role and the `Str` role
together. `$n + 8` uses its `Int` half; `$n.flip` (reverse the characters) uses its
`Str` half and gives back `"24"`.

## Each numeric kind has its allomorph

A decimal gives a `RatStr`, and the value still works as an ordinary `Rat` in
arithmetic.

```raku
say <1.5>.^name;
for <1 2.5 3> {
    say "$_ is {.^name}";
}
```
```output
RatStr
1 is IntStr
2.5 is RatStr
3 is IntStr
```

Iterating a `<…>` list yields an allomorph per word, each typed by what it looks
like — the integers become `IntStr`, the decimal becomes `RatStr`.

## Comparing both ways

Because an allomorph carries both values, it matches numerically with `==` and
stringwise with `eq`.

```raku
say <42> == 42;
say <42> eq "42";
```
```output
True
True
```

## Notes

- The allomorph types are `IntStr`, `RatStr`, `NumStr`, and `ComplexStr` — one per
  numeric kind (`Int`, `Rat`, `Num`, `Complex`). See
  [Number forms](/literals/numbers/).
- `<…>` only makes an allomorph when the word *is* numeric; `<hello>` is a plain
  `Str`, and a list like `<a 1 b>` mixes `Str` and `IntStr` elements.
- Force just the number with a numeric coercion (`+$n` or `$n.Int`) or just the
  string with `~$n` — the result is then a plain `Int`/`Str`, not an allomorph.
- Command-line arguments in `@*ARGS` and words from `.words` arrive as allomorphs,
  so `"3 4 5".words.sum` works without an explicit conversion.
