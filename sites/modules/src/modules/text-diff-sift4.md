---
name: Text::Diff::Sift4
version: 2.0.1
auth: zef:MasterDuke
kind: Distribution · text comparison
summary: The Sift4 string-distance approximation — one linear pass counting
  matches inside a sliding offset window — as a cheap stand-in for Levenshtein.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:MasterDuke/Text::Diff::Sift4
source: https://github.com/masterduke17/text-diff-sift4.git
---

## What it is for

Levenshtein distance costs the product of the two string lengths. For a search
box firing on every keystroke against ten thousand product names, that product
is the whole budget. Sift4 trades exactness for a single linear pass: walk both
strings together, count the characters that match within a bounded offset, and
charge for the transpositions you had to step over.

The result is a Levenshtein-*like* number in O(n) rather than O(nm), which is
the right trade when you are ranking candidates rather than counting edits.

## Measuring a distance

```raku name="sift"
use Text::Diff::Sift4;

for <kitten sitting>, <Sift Sifter>, <London Londo>, <abcdefg abcdefg>,
    <a b>, ('Hello World', 'Hello Wolrd') -> ($a, $b) {
    say sprintf('%-12s %-12s -> %d', $a, $b, sift4($a, $b));
}
say sift4('', ''), ' ', sift4('', 'abc'), ' ', sift4('abc', '');
```

```output
kitten       sitting      -> 3
Sift         Sifter       -> 2
London       Londo        -> 1
abcdefg      abcdefg      -> 0
a            b            -> 1
Hello World  Hello Wolrd  -> 1
0 3 3
```

The signature is all-native — `sift4(str, str, int, int)` — and the two
trailing integers are the tuning knobs. `$maxOffset` bounds how far the scan
will look for a displaced match; `$maxDistance` makes it give up early.

## Tuning the two knobs

```raku name="knobs"
use Text::Diff::Sift4;

my ($a, $b) = 'abcdefghijklm', 'mlkjihgfedcba';

say 'defaults            : ', sift4($a, $b);
say 'maxOffset 1         : ', sift4($a, $b, 1);
say 'maxOffset 12        : ', sift4($a, $b, 12);
say '';
say 'maxDistance sweep 0..6:';
say '  ', (0..6).map({ "md=$_:" ~ sift4($a, $b, 10, $_) }).join('  ');
```

```output
defaults            : 9
maxOffset 1         : 11
maxOffset 12        : 8

maxDistance sweep 0..6:
  md=0:9  md=1:2  md=2:3  md=3:4  md=4:5  md=5:6  md=6:7
```

Two things fall out of that sweep. A **larger** `$maxOffset` gives a
**smaller** distance, because the scan can reach further to pair up displaced
characters. And `$maxDistance` does not clamp the answer, it aborts the scan
and returns `$maxDistance + 1` — so `md=3` gives 4, `md=5` gives 6, and only
from `md=9` upwards do you get the real 9. Using it as a threshold test works;
reading the number it returns as a distance does not. `$maxDistance = 0`
disables the bail-out rather than meaning "give up at once".

## The one thing to know

Sift4 systematically **underestimates** the true edit distance, and it does so
on short ordinary words — not only on the pathological ones.

```raku name="underestimate"
use Text::Diff::Sift4;

sub lev(Str $a, Str $b) {
    my @p = ^($b.chars + 1);
    for $a.comb.kv -> $i, $ca {
        my @c = $i + 1,;
        for $b.comb.kv -> $j, $cb {
            @c.push: min(@p[$j+1] + 1, @c[$j] + 1, @p[$j] + ($ca eq $cb ?? 0 !! 1));
        }
        @p = @c;
    }
    @p[*-1]
}

for <kitten sitting>, <flaw lawn>, <banana ananas>,
    <abcd dcba>, <xyzabcdefghij abcdefghijxyz> -> ($a, $b) {
    my ($s, $l) = sift4($a, $b), lev($a, $b);
    say sprintf('%-14s %-14s sift4=%-2d levenshtein=%-2d %s',
        $a, $b, $s, $l, $s == $l ?? 'agree' !! 'UNDERESTIMATES');
}
```

```output
kitten         sitting        sift4=3  levenshtein=3  agree
flaw           lawn           sift4=1  levenshtein=2  UNDERESTIMATES
banana         ananas         sift4=1  levenshtein=2  UNDERESTIMATES
abcd           dcba           sift4=3  levenshtein=4  UNDERESTIMATES
xyzabcdefghij  abcdefghijxyz  sift4=3  levenshtein=6  UNDERESTIMATES
```

`kitten`/`sitting` is the textbook example and Sift4 gets it exactly right,
which is precisely what lulls people into treating it as a drop-in
replacement. Then `flaw`/`lawn` scores 1 against a true 2, and `banana`/
`ananas` does the same. A fuzzy-match threshold of "distance ≤ 1" therefore
admits pairs that are two edits apart, silently.

Treat the number as a ranking signal, not as an edit count. If you need a
threshold with a guarantee behind it, compute the real distance on the
shortlist Sift4 produces.

## Where the two engines differ

Nowhere. Every spike in this page — the reference pairs, the two sweeps, the
Levenshtein comparison, and a Unicode check where both spellings of `café`
measure distance 0 — produced byte-identical output under Raku++ and Rakudo.
It is the rare module whose behaviour does not vary at all.

Worth noting for its own sake: because the parameters are native `str`, the
strings still carry Raku's grapheme semantics, so a combining acute and a
precomposed one compare equal at distance 0, and `漢字` against `漢字字` is 1.
Sift4 here is grapheme-based, which is the right answer for a distance.
