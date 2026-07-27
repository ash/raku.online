---
title: String tests & search
slug: string-tests
status: full
order: 15
summary: Boolean substring tests and finding positions — contains, starts-with, indices.
---

Beyond `.index`, `Str` has Boolean predicates for the common "does it contain / begin
/ end with" questions, plus `.indices` for every position.

## Boolean substring tests

```raku
say "hello".contains("ell");
say "hello".starts-with("he");
say "hello".ends-with("lo");
```
```output
True
True
True
```

These read better than comparing an `.index` against `-1` (Raku returns `Nil`, not
`-1`, for a missing substring anyway).

## All positions — indices

`.indices` returns every start position of the substring, in order.

```raku
say "hello".indices("l");
```
```output
(2 3)
```

## Notes

- `.contains`, `.starts-with`, `.ends-with` accept a string or a regex, so
  `.contains(/\d/)` tests for any digit.
- `.index` returns the first position (or `Nil`); `.rindex` searches from the end.
- For extracting the matched pieces rather than testing, use `.comb` or a regex
  match — see [String methods](/methods/string/).
