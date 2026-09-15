---
name: Math::DistanceFunctions::Edit
version: 0.1.3
auth: zef:antononcube
kind: Distribution · text
summary: Edit distance with transpositions counted as one operation, done
  in C — how many single-character changes turn one string into another,
  for spelling suggestions and fuzzy matching.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: NativeHelpers::Array
raku-land: https://raku.land/zef:antononcube/Math::DistanceFunctions::Edit
source: https://github.com/antononcube/Raku-Math-DistanceFunctions-Edit
---

## What it is for

"Did you mean …?" needs a number for how wrong a word is, and edit distance
is that number: the count of insertions, deletions and substitutions
between two strings. Damerau's variant adds a fourth operation, swapping
two adjacent characters, because that is the typo people actually make —
`teh` is one mistake away from `the`, not two.

The arithmetic is a table of *m* by *n* cells, which is exactly the kind of
inner loop an interpreter is slow at, so this distribution does it in C and
reaches it through NativeCall. Where a pure-Raku implementation is fine for
one comparison, this one is for the loop over every candidate in a
dictionary.

## Two subs

```raku name="distance"
use Math::DistanceFunctions::Edit;

say edit-distance('kitten', 'sitting');
say edit-distance('abcd', 'acbd');
say edit-distance('', 'abc');
say edit-distance('same', 'same');
say edit-distance('Raku', 'raku');
say edit-distance('Raku', 'raku', :i);
say edit-distance-fast('kitten', 'sitting');
say edit-distance(<a b c>, <a x c>);
```

```output
3
1
3
0
1
0
3
1
```

`edit-distance` is the general one: two strings, or two lists, with an
optional `:i` to fold case first. `edit-distance-fast` is the strings-only
path without the case option. The second line is where Damerau shows: `abcd`
to `acbd` is one transposition here, where plain Levenshtein would charge
two edits.

It counts graphemes, not bytes or codepoints, so a composed and a
decomposed accented character are the same character:

```raku name="graphemes"
use Math::DistanceFunctions::Edit;

my $composed   = "caf\x[00E9]";
my $decomposed = "cafe\x[0301]";
say $composed.chars, ' ', $decomposed.chars;
say edit-distance($composed, $decomposed);
say edit-distance('café', 'cafe');
say edit-distance('日本', '日本語');
```

```output
4 4
0
1
1
```

## The one thing to know

It is the *restricted* Damerau–Levenshtein distance, which means it is not
a metric: the triangle inequality does not hold. Each substring may be
edited only once, so a transposition followed by an insertion in the same
place is not available:

```raku name="not-a-metric"
use Math::DistanceFunctions::Edit;

my $direct = edit-distance('ca', 'abc');
my $via    = edit-distance('ca', 'ac') + edit-distance('ac', 'abc');
say $direct;
say $via;
say $direct <= $via;
```

```output
3
2
False
```

Going through the intermediate string costs less than going straight there,
which a distance is not allowed to do. For spelling suggestions and fuzzy
matching nothing notices. For anything that *indexes* by distance — a
BK-tree, a metric ball tree, clustering that prunes with the triangle
inequality — the structure's correctness argument depends on the property
this function lacks, and the result will be quietly incomplete rather than
wrong-looking.
