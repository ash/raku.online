---
title: String methods
slug: string
status: full
order: 10
summary: The everyday Str toolkit — case, trimming, indexing, splitting into pieces.
---

`Str` carries a large method set. These are the ones you reach for constantly:
changing case, trimming, locating and slicing substrings, and breaking a string into
characters or matches.

## Length, case, reversal

```raku
say "Hello".chars;
say "Hello".uc;
say "Hello".flip;
```
```output
5
HELLO
olleH
```

## Trim, index, substr

`trim` removes surrounding whitespace, `index` finds a substring's position
(zero-based), and `substr` extracts a slice by start and length.

```raku
say "  hi  ".trim;
say "hello".index("l");
say "hello".substr(1, 3);
```
```output
hi
2
ell
```

## comb — break into pieces

`comb` returns the matching pieces of a string: with no argument, each character;
with a regex, each match.

```raku
say "hello".comb;
say "a1b2c3".comb(/\d/);
```
```output
(h e l l o)
(1 2 3)
```

## trans — translate characters

`trans` maps characters to replacements, like `tr///` in other languages.

```raku
say "hello".trans("el" => "ip");
```
```output
hippo
```

## Notes

- `.uc`/`.lc`/`.tc`/`.fc` cover upper, lower, title, and fold case; `.wordcase`
  title-cases each word.
- `.contains`, `.starts-with`, `.ends-with` are the Boolean substring tests;
  `.indices` finds *all* positions.
- `.split` (a routine and a method) breaks on a separator, while `.comb` keeps the
  matching parts — they are complements.
