---
title: Grammars
slug: grammars
status: full
order: 50
summary: Named, composable regexes as a class — the basis of Raku's parsing.
---

A `grammar` is a class whose methods are regexes. Rules reference one another as
subrules, so a grammar describes a whole language, not just one pattern. `.parse`
runs it against a string and returns a Match tree.

## A tiny grammar

`token` and `rule` declare named patterns; `rule` additionally makes whitespace
significant (handy between tokens). Parsing starts at `TOP`.

```raku
grammar Calc {
    rule TOP { <num> "+" <num> }
    token num { \d+ }
}
say Calc.parse("2 + 3") ?? "parsed" !! "failed";
```
```output
parsed
```

## Reading the parse tree

Subrules capture by name, so the result indexes like a nested Match.

```raku
grammar KV {
    token TOP { <key> "=" <value> }
    token key { \w+ }
    token value { \N+ }
}
my $m = KV.parse("name=Ada");
say ~$m<key>;
say ~$m<value>;
```
```output
name
Ada
```

## Actions — building a result with make / made

A grammar alone gives you a parse tree; an **actions class** turns it into a value.
Pass `actions => SomeClass` to `.parse`, and for each rule the method of the same name
runs with the match `$/`. Inside it, `make` attaches a computed result to that match,
and `.made` reads back what a subrule made — so results bubble up from the leaves to
`TOP`.

```raku
grammar Calc {
    token TOP { <sum> }
    token sum { <int>+ % "+" }
    token int { \d+ }
}
class Actions {
    method TOP($/) { make $<sum>.made }
    method sum($/) { make $<int>».made.sum }
    method int($/) { make +$/ }
}
say Calc.parse("1+2+3", actions => Actions).made;
```
```output
6
```

Each `int` makes its numeric value; `sum` sums the values its `int` subrules made;
`TOP` passes that up — so `.made` on the final match is the evaluated total. This is
how a grammar becomes an interpreter or an AST builder.

## Notes

- `make $x` stores `$x` as this match's result; `$/.made` (or `$<subrule>.made`) reads
  it. `make` inside a bare `{ … }` block works in a plain regex too, but the pattern
  is cleanest with a dedicated actions class.
- `token` is non-backtracking and ignores declared whitespace; `rule` is like
  `token` but treats whitespace between atoms as `<.ws>`; `regex` backtracks. Reach
  for `token` by default.
- `.parse` requires the whole string to match `TOP`; `.subparse` allows a partial
  match from the start.
- Pair a grammar with an **actions class** to build a result (an AST, a data
  structure) as it parses — the standard way to turn a parse into something useful.
