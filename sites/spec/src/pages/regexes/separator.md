---
title: Separated quantifiers  % and %%
slug: separator
status: full
order: 42
summary: Match a repeated pattern with a separator between the repeats, in one construct.
---

The `%` modifier on a quantifier matches a repeated atom **separated** by another
pattern — the clean way to parse comma- or dash-delimited lists without writing the
separator logic by hand. `%%` is the variant that also allows a trailing separator.

## A separated list

`(\d)+ % "-"` matches one or more digits separated by `-`, capturing the digits.

```raku
if "1-2-3" ~~ / (\d)+ % "-" / { say $0.join(",") }
```
```output
1,2,3
```

The `+ % "-"` says "one or more, with `-` between them" — so the separators are
consumed but not captured.

## Named atoms

The atom can be a subrule, which is how a grammar parses a delimited list.

```raku
my token num { \d+ }
"10,20,30" ~~ / <num>+ % "," /;
say $<num>.map(~*).join("|");
```
```output
10|20|30
```

## Notes

- `%%` allows an optional **trailing** separator: `<num>+ %% ","` matches `"1,2,3,"`
  as well as `"1,2,3"`.
- The separator is any regex atom — a literal, a character class, or `\s*` for
  optional surrounding whitespace.
- This is the idiomatic way to write list rules in a
  [grammar](/regexes/grammars/): `rule list { <item>+ % ',' }`.
