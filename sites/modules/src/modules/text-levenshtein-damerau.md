---
name: Text::Levenshtein::Damerau
version: 0.3.0
auth: github:ugexe
kind: Distribution · text
summary: How many single-character edits turn one string into another —
  plain Levenshtein, and the Damerau variant that counts a swapped pair as
  one edit — with a cut-off for when you only care whether it is close.
status: full
suite: 3 files, green
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/github:ugexe/Text::Levenshtein::Damerau
source: https://github.com/ugexe/Raku-Text--Levenshtein--Damerau
---

## What it is for

"Did you mean `commit`?" needs a number for how far `comit` is from it, and
edit distance is that number: the count of insertions, deletions and
substitutions between two strings. Damerau's variant adds a fourth edit, the
transposition of two adjacent characters, which is the typo people actually
make — `teh` is one edit from `the`, not two. This distribution is both, as
two subs, and it is what `zef` uses to suggest the module you probably
meant.

## Two distances and a cut-off

```raku name="distances"
use Text::Levenshtein::Damerau;

say ld('kitten', 'sitting'), ' ', dld('kitten', 'sitting');
say ld('abcd', 'acbd'), ' ', dld('abcd', 'acbd');
say ld('', 'abc'), ' ', dld('same', 'same');
say dld('rakudo', 'raku', 1).defined;
```

```output
3 3
2 1
3 0
False
```

`ld` is Levenshtein and `dld` is Damerau-Levenshtein; they agree until a
transposition is the cheapest edit, as on the second line, where swapping
`bc` costs one edit under Damerau and two — a deletion and an insertion —
under Levenshtein. Both take an optional third argument, a maximum.

## The one thing to know

The maximum does not clamp, it gives up. `dld('rakudo', 'raku', 1)` is not
2 and not 1: it is an *undefined Int*, because the distance passed the
limit and the sub stopped counting. That is the efficient answer for a
"close enough?" test over a long list of candidates — most comparisons stop
early — and it means the result has to be checked with `.defined` before it
is compared or sorted. A loop that does `min` over the distances will find
the undefined ones sorting as zero, and pick the worst candidate as the
best.
