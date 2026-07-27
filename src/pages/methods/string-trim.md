---
title: Trimming — trim / chomp / chop
slug: string-trim
status: full
order: 30
summary: Remove whitespace or characters from the ends of a string.
---

Several methods remove characters from a string's ends: `trim` (and its one-sided
`trim-leading`/`trim-trailing`) strip whitespace, `chomp` removes a trailing newline,
and `chop` removes trailing characters.

## One-sided trimming

`.trim-leading` strips leading whitespace; `.trim-trailing` strips trailing. (`.trim`
does both — see [String methods](/methods/string/).)

```raku
say "  hi  ".trim-leading ~ "|";
say "  hi  ".trim-trailing ~ "|";
```
```output
hi  |
  hi|
```

## chomp and chop

`.chomp` removes a single trailing newline (if present); `.chop` removes the last
character (or the last `n` with an argument).

```raku
say "line\n".chomp;
say "hello".chop;
say "hello".chop(2);
```
```output
line
hell
hel
```

## Notes

- `.chomp` only removes a *newline*, and only one — it's the right tool for cleaning
  a line read from input, where `.trim` might strip meaningful spaces.
- `.chop` removes characters regardless of what they are; `.chop(n)` removes `n`.
- All of these return a new string; the original is unchanged (use `.=chomp` etc. to
  mutate in place).
