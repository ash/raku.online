---
title: Named regexes as subrules
slug: named-rules
status: full
order: 44
summary: Define reusable patterns with my token / my regex and call them as <name>.
---

A pattern can be given a name with `my token` or `my regex`, then invoked inside
another regex as `<name>` — a **subrule**. The submatch is captured under that name,
readable as `$<name>`. This is the same mechanism grammars use, at a smaller scale.

## A named token

`token` is the non-backtracking form (the usual default). Call it with `<name>` and
read its match from `$<name>`.

```raku
my token num { \d+ }
say so "x42y" ~~ /<num>/;
say ~$<num>;
```
```output
True
42
```

## A named regex

`regex` is the backtracking form; otherwise it works the same as a subrule.

```raku
my regex id { <[a..z]>+ }
"hello123" ~~ /<id>/;
say ~$<id>;
```
```output
hello
```

`<id>` matches the leading lowercase run `hello`, stopping at the first digit.

## Notes

- `<name>` both matches the subrule and captures it; use `<.name>` to match without
  capturing.
- Subrules can call other subrules, which is exactly how a
  [grammar](/regexes/grammars/) is built — a grammar is a named collection of
  these rules.
- A lexical `my token`/`my regex` shadows a built-in subrule of the same name
  (`<ws>`, `<alpha>`, …), so `<ident>` uses *your* definition inside the scope.
