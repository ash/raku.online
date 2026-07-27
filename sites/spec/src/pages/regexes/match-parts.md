---
title: prematch & postmatch — text around a match
slug: match-parts
status: full
order: 33
summary: The slices of the string before and after what a regex matched.
---

A `Match` knows not just what it matched, but where — so it can hand back the text
**before** the match (`.prematch`) and **after** it (`.postmatch`). Together with the
match itself, they reconstruct the whole string, which makes them handy for splitting
around a marker or peeling a value out of context.

## Before and after

```raku
"2026-07-21" ~~ / \- /;
say $/.prematch;
say $/.postmatch;
```
```output
2026
07-21
```

The regex matched the first `-`; `.prematch` is everything up to it, `.postmatch`
everything after.

## Peeling a value out

Combined with a capture, this pulls a value while keeping what surrounded it.

```raku
"key=value;" ~~ / "=" (\w+) /;
say ~$0;
say $/.prematch;
say $/.postmatch;
```
```output
value
key
;
```

## Notes

- `.prematch` and `.postmatch` are relative to the *whole* match (`$/`), not to any
  capture inside it.
- `$/.prematch ~ ~$/ ~ $/.postmatch` reconstructs the original string.
- For splitting on every occurrence rather than the first, reach for
  [`.split`](/methods/split/) or [`.comb`](/methods/string/); prematch/postmatch are
  about a single match's surroundings.
