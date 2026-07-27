---
title: Unicode & graphemes
slug: unicode
status: full
order: 45
summary: Grapheme-aware length, codepoints, names, values, and normalization.
---

Raku strings are sequences of **graphemes** (what a reader perceives as a character),
not bytes or codepoints. `.chars` counts graphemes, and Raku++ normalises combining
sequences the way Rakudo does — so a base letter plus a combining mark is one
character *and* composes to a single codepoint.

## Grapheme-aware length

`.chars` counts graphemes, so a base letter plus a combining mark is **one**
character.

```raku
say "café".chars;
my $s = "e" ~ "\x[301]";
say $s.chars;
```
```output
4
1
```

## Codepoints, names, and values

`.ord`/`.chr` convert between a character and its codepoint; `.uniname` gives the
Unicode name, `.uniprop` a property, `.unival` a numeric value.

```raku
say "A".ord;
say 65.chr;
say "α".uniname;
say "½".unival;
```
```output
65
A
GREEK SMALL LETTER ALPHA
0.5
```

## Normalization

A composed and a decomposed spelling of the same text compare equal, because both
normalise: `e` plus a combining acute becomes the single codepoint `é`.

```raku
my $s = "e" ~ "\x[301]";
say $s.codes;
say $s eq "é";
```
```output
1
True
```

`.codes` is `1` — the two-codepoint input was composed to one. The `.NFD`/`.NFC`
methods expose the forms explicitly: decomposed is two codepoints, composed is one.

```raku
say "é".NFD.codes;
say "é".NFC.codes;
```
```output
2
1
```

## Notes

- `.codes` counts codepoints, `.chars` counts graphemes — they differ whenever a
  grapheme is built from more than one codepoint (an emoji with a skin-tone modifier,
  say), even after normalization.
- `.ords` returns all codepoints as a list; `.uniprop` exposes character properties
  (`"A".uniprop` is `Lu`, an uppercase letter).
- `.NFD`, `.NFC`, `.NFKD`, `.NFKC` give the four Unicode normalization forms as
  codepoint sequences.
