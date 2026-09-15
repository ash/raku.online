---
name: Text::Levenshtein
version: 0.2.4
auth: zef:thundergnat
kind: Distribution · string distance
summary: Classic full-matrix edit distance — and it returns an Array, so every
  numeric comparison you would naturally write answers a different question.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:thundergnat/Text::Levenshtein
source: git://github.com/thundergnat/Text-Levenshtein.git
---

## What it is for

Levenshtein distance counts the insertions, deletions and substitutions
needed to turn one string into another. It is the workhorse behind "did you
mean…?", fuzzy joins, spell-check candidate ranking and OCR scoring.

This distribution has one exported sub. It compares a source string against
any number of targets and returns one number per target. The Perl 5 original's
`fastdistance` was not ported.

## Measuring a distance

```raku name="basics"
use Text::Levenshtein;

say 'distance("kitten", "sitting")   = ', distance('kitten', 'sitting');
say 'distance("foo", <four foo bar>) = ', distance('foo', <four foo bar>);
say 'distance("", "abc")             = ', distance('', 'abc');
say 'distance("abc", "")             = ', distance('abc', '');
say 'distance("abc") with no target  = ', distance('abc');
say '';
say 'comparison is case-sensitive and does no folding:';
say '  distance("ABC", "abc")        = ', distance('ABC', 'abc');
```

```output
distance("kitten", "sitting")   = [3]
distance("foo", <four foo bar>) = [2 0 3]
distance("", "abc")             = [3]
distance("abc", "")             = [3]
distance("abc") with no target  = []

comparison is case-sensitive and does no folding:
  distance("ABC", "abc")        = [3]
```

It counts **graphemes**, because the implementation is built on `.chars` and
`.substr`:

```raku name="graphemes"
use Text::Levenshtein;

my $zwj = "\c[WOMAN]\c[ZERO WIDTH JOINER]\c[PERSONAL COMPUTER]";
say 'a ZWJ sequence: chars=', $zwj.chars, ' codepoints=', $zwj.ords.elems;
say '  distance("", it) = ', distance('', $zwj)[0];
say '';
my $cjk = "\c[CJK UNIFIED IDEOGRAPH-6F22]\c[CJK UNIFIED IDEOGRAPH-5B57]";
say 'two CJK ideographs, drop one: ', distance($cjk, $cjk.substr(0,1))[0];
```

```output
a ZWJ sequence: chars=1 codepoints=3
  distance("", it) = 1

two CJK ideographs, drop one: 1
```

Raku normalises string literals to NFC, so a decomposed `e` plus a combining
acute is `eq` its precomposed form and their distance is 0 — decomposition is
never counted as an extra edit.

## The one thing to know

`distance` always returns an `Array`. Comparing that `Array` to a number
compares the **number of targets**, not the distance — so the guard you meant
to write accepts everything.

```raku name="array-trap"
use Text::Levenshtein;

my $d = distance('foo', 'four');
say 'distance("foo","four")          = ', $d.raku;
say '  == 2                          ? ', ($d == 2).raku, '   <- the real distance';
say '  == 1                          ? ', ($d == 1).raku, '   <- the target COUNT';
say '';
say 'distance("foo","foo") == 0      ? ', (distance('foo','foo') == 0).raku;
say 'distance("a","zzzzzzzzzz") < 3  ? ', (distance('a','zzzzzzzzzz') < 3).raku,
    '   <- the real distance is ', distance('a','zzzzzzzzzz')[0];
say '';
say 'the right way is to subscript:';
say '  distance("a","zzzzzzzzzz")[0] = ', distance('a','zzzzzzzzzz')[0];
```

```output
distance("foo","four")          = $[2]
  == 2                          ? Bool::False   <- the real distance
  == 1                          ? Bool::True   <- the target COUNT

distance("foo","foo") == 0      ? Bool::False
distance("a","zzzzzzzzzz") < 3  ? Bool::True   <- the real distance is 10

the right way is to subscript:
  distance("a","zzzzzzzzzz")[0] = 10
```

The Perl 5 original returns a scalar in scalar context; Raku has no scalar
context, so the single-target call — the overwhelmingly common one — hands
back a one-element `Array` that numifies to `1`. A fuzzy-match guard written
as `if distance($a, $b) <= $threshold` accepts every pair, and
`if distance($a, $b) == 0` rejects identical strings. Both compile, neither
warns, and the mistake looks exactly like working code.

There is a second edge behind the same door: `distance($s)` with no targets
returns `[]`, which numifies to `0` — so the same guard flips to rejecting
everything the moment your target list happens to be empty.

## Where the two engines differ

Nothing in this module's behaviour differs between the engines: the numbers,
the types and the failures all match. Only the cost does, and in Raku++'s
favour.

```raku name="untyped"
use Text::Levenshtein;

say 'the sub is untyped, so anything that stringifies works:';
say '  distance(12, 13)     = ', distance(12, 13).raku;
say '  distance("1", 1)     = ', distance('1', 1).raku;
say '  distance(1.0, 1)     = ', distance(1.0, 1).raku, '   <- "1" vs "1"';
say '';
say '*@t is a FLATTENING slurpy, so a list is spread into separate targets:';
my @a = <four foo>;
say '  distance("foo", @a, "bar") = ', distance('foo', @a, 'bar').raku;
say '  you cannot pass a list as one target.';
```

```output
the sub is untyped, so anything that stringifies works:
  distance(12, 13)     = [1]
  distance("1", 1)     = [0]
  distance(1.0, 1)     = [0]   <- "1" vs "1"

*@t is a FLATTENING slurpy, so a list is spread into separate targets:
  distance("foo", @a, "bar") = [2, 0, 3]
  you cannot pass a list as one target.
```

The implementation builds the whole `$n × $m` matrix as a nested Raku `Array`
with no banding and no early exit. A 300-character pair takes roughly a
quarter of a second under Raku++ and about half a second under Rakudo — fine
for a handful of comparisons, far too slow to sweep a dictionary.
