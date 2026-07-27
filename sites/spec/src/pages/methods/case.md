---
title: Case methods
slug: case
status: full
order: 20
summary: Upper, lower, title, and per-word case conversions.
---

`Str` offers a family of case conversions: `.uc`/`.lc` (upper/lower), `.tc`/`.tclc`
(title-case the first letter), and `.wordcase` (title-case every word).

## Title-casing

`.tc` upper-cases the first character; `.tclc` also lower-cases the rest — useful for
normalising a word.

```raku
say "hello world".tc;
say "hELLO".tclc;
```
```output
Hello world
Hello
```

`.tc` touches only the first letter, so `hello world` becomes `Hello world` (the `w`
stays lower).

## wordcase — every word

`.wordcase` title-cases **each** word, not just the first.

```raku
say "hello world".wordcase;
```
```output
Hello World
```

## Notes

- `.uc` and `.lc` are the plain upper/lower conversions and match Rakudo.
- `.fc` is *fold case* — a canonical form for case-insensitive comparison, distinct
  from `.lc`.
- Unicode-aware: case methods handle accented letters and multi-codepoint graphemes,
  not just ASCII.
