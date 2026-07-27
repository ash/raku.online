---
title: Conjunction & capture aliases
slug: conjunction
status: full
order: 24
summary: Match several patterns at one position with & / &&, alias captures into named or numbered variables, and find every match with :exhaustive.
---

Most regex constructs consume input left to right. A few instead constrain or
re-label a match in place: the conjunction operators require several patterns to
hold at the **same** position, capture aliases give a group a name or number, and
`:exhaustive` returns every possible match rather than the first.

## Conjunction — & and &&

`A & B` matches only where **both** `A` and `B` match starting at the same
position. The overall match spans the **last** branch, so put the branch whose
length you want the match to take last.

```raku
say ~("abcXYZ" ~~ / \w+ & <[a..z A..Z]>+ /);
say ~("2026-07" ~~ / \d+ & <?before \d\d\d\d> \d+ /);
```
```output
abcXYZ
2026
```

`&&` is the same test with tighter precedence — it binds closer than alternation,
so it groups a conjunction inside a larger pattern without extra brackets.

```raku
say so "foobar" ~~ / <:L>+ && <-[0..9]>+ /;
```
```output
True
```

## Numbered capture aliases

`$N=( … )` gives a capturing group an explicit index `N` instead of the
position it would otherwise receive; automatic numbering then resumes at `N+1`.

```raku
if "abc" ~~ / $0=(.) (.) / {
    say ~$0;
    say ~$1;
}
```
```output
a
b
```

## Named array-capture aliases

`@<name>=( … )` inside a quantified group collects **one entry per iteration**
into a named, list-valued capture — instead of the single last match a plain
capture would keep.

```raku
if "a1b2c3" ~~ / [ @<L>=(<:L>) \d ]+ / {
    say @<L>.elems;
    say @<L>.join(",");
}
```
```output
3
a,b,c
```

## :exhaustive — every match

`m:exhaustive` (`:ex`) returns every match at every position and length, not just
the first or the leftmost-longest.

```raku
say ("aaa" ~~ m:exhaustive/a+/).map(~*);
```
```output
(aaa aa a aa a a)
```

## Where Raku++ excels

The `@<name>=(…)` array alias has a hash-valued sibling, `%<name>=(…)`, which
collects each matched substring as a **key** (reached through `$<name>`). Rakudo
reserves `%`-sigil variables in regex syntax and rejects the construct at compile
time (*"The use of hash variables in regexes is reserved"*), so this one is
Raku++-only.

```raku
if "a1b2c3" ~~ / [ %<seen>=(<:L>) \d ]+ / {
    say $<seen>.keys.sort;   # Raku++: (a b c)   ·   Rakudo: won't compile
}
```

The official suite has a whole 116-test file for hash aliases —
[`S05-capture/hash.t`](https://github.com/Raku/roast/blob/master/S05-capture/hash.t)
(spec reference `L<S05/Hash aliasing>`):

```
ok("  a b\tc" ~~ m/%<chars>=( \s+ \S+ )/, 'Named unrepeated hash capture');
ok($/<chars>{'  a'}:exists, 'One key captured');
```

Current Rakudo no longer compiles the `%<…>=(…)` syntax (*"The use of hash
variables in regexes is reserved"*), so it cannot run that file at all. Raku++ does.

## Notes

- `&` sits at the same precedence level as alternation `|`; `&&` binds tighter,
  mirroring the `|` / `||` pair. Reach for `&&` when a conjunction is one branch of
  a larger alternation.
- A capture alias names or numbers **the group it is attached to** — it does not
  add a level of nesting, so `$0=(.)` still captures exactly the parenthesised atom.
- `:exhaustive` can return a quadratic number of matches on long inputs (every
  start × every length), so it is an analysis tool, not something to run on bulk text.
