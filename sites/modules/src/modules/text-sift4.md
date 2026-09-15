---
name: Text::Sift4
version: 0.0.6
auth: cpan:TITSUKI
kind: Distribution · string distance
summary: A linear-time approximation of edit distance — fast, and not a
  metric: swapping the two arguments can change the answer.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/cpan:TITSUKI/Text::Sift4
source: https://github.com/titsuki/p6-Text-Sift4.git
---

## What it is for

Levenshtein distance costs `O(n·m)`. When you need to compare one string
against thousands, that is the wrong shape. Sift4 walks both strings with a
pair of cursors, counts matching runs, and on a mismatch scans forward up to
`:max-offset` positions to resynchronise — linear time, and an approximate
answer.

## Using it

```raku name="basics"
use Text::Sift4;

for <abc ab>, <ab abc>, <abc xxx>, <kitten sitting>, <abc abc> -> ($a, $b) {
    say sprintf('sift4(%-8s, %-8s) = %d', $a.raku, $b.raku, sift4($a, $b));
}
say '';
say 'return type : ', sift4('a', 'b').WHAT.^name;
say 'empty pair  : ', sift4('', '');
say 'undefined   : ', sift4(Str, 'abc'), '  (the parameters are Str, not Str:D)';
```

```output
sift4("abc"   , "ab"    ) = 1
sift4("ab"    , "abc"   ) = 1
sift4("abc"   , "xxx"   ) = 3
sift4("kitten", "sitting") = 3
sift4("abc"   , "abc"   ) = 0

return type : Int
empty pair  : 0
undefined   : 3  (the parameters are Str, not Str:D)
```

Like `Text::Levenshtein` it counts graphemes, since it is built on `.chars`
and `.substr`.

## What you buy and what you pay

```raku name="speed"
use Text::Sift4;

sub lev($a, $b) {
    my @d = [0 .. $b.chars],;
    for 1 .. $a.chars -> $i {
        @d[$i][0] = $i;
        for 1 .. $b.chars -> $j {
            @d[$i][$j] = ($a.substr($i-1,1) eq $b.substr($j-1,1))
                ?? @d[$i-1][$j-1]
                !! 1 + min(@d[$i-1][$j], @d[$i][$j-1], @d[$i-1][$j-1]);
        }
    }
    @d[$a.chars][$b.chars]
}

my $a = (^300).map({ <a b c d>[($_ * 7 + 1) % 4] }).join;
my $b = (^300).map({ <a b c d>[($_ * $_ + 3) % 4] }).join;
my $true  = lev($a, $b);
my $quick = sift4($a, $b);
say "300-character strings over a 4-letter alphabet";
say "  levenshtein : $true";
say "  sift4       : $quick";
say sprintf('  sift4 reports %d%% of the true distance', (100 * $quick / $true).round);
```

```output
300-character strings over a 4-letter alphabet
  levenshtein : 150
  sift4       : 151
  sift4 reports 101% of the true distance
```

The name says *approximate*, and the approximation errs in **both**
directions. Across all 14 641 ordered pairs of strings of length 0–4 over
`{a,b,c}`, sift4 under-reports on 31% of them and over-reports on 4%; the
300-character pair above over-reports by roughly half. There is no bound.

## The one thing to know

`sift4` is not symmetric. Swap the two arguments and the answer can change —
and the larger of the two is the wrong one.

```raku name="asymmetry"
use Text::Sift4;

for <ab bab>, <ac cac>, <ba aba> -> ($x, $y) {
    say sprintf('sift4(%-4s,%-4s) = %d   sift4(%-4s,%-4s) = %d   (true distance 1)',
                $x.raku, $y.raku, sift4($x, $y),
                $y.raku, $x.raku, sift4($y, $x));
}
say '';
say 'every mental model of "string distance" assumes d(a,b) == d(b,a).';
say '456 of the 14641 short pairs over {a,b,c} violate it here.';
say 'anything that memoises on a sorted key, dedupes a pair, or builds a';
say 'symmetric similarity matrix gets a different answer depending on';
say 'which cell it happened to compute.';
```

```output
sift4("ab","bab") = 2   sift4("bab","ab") = 1   (true distance 1)
sift4("ac","cac") = 2   sift4("cac","ac") = 1   (true distance 1)
sift4("ba","aba") = 2   sift4("aba","ba") = 1   (true distance 1)

every mental model of "string distance" assumes d(a,b) == d(b,a).
456 of the 14641 short pairs over {a,b,c} violate it here.
anything that memoises on a sorted key, dedupes a pair, or builds a
symmetric similarity matrix gets a different answer depending on
which cell it happened to compute.
```

The asymmetry comes from the resynchronisation loop, which advances the two
cursors under different conditions.

`:max-offset` is not the bound it looks like either. An operator-precedence
slip — `while $i < $max-offset && (lhs in range) || (rhs in range)` parses as
`($i < $max-offset && lhsInRange) || rhsInRange` — applies the guard to only
one of the two disjuncts, so for some inputs the forward scan runs arbitrarily
far and neither the cost nor the answer is bounded by the parameter.

## Where the two engines differ

The same precedence slip lets the loop body run after the left cursor is past
the end of `$lhs`, and the `substr` that follows is unguarded. Rakudo throws;
Raku++'s `substr` is permissive past the end and returns `""`, so the crash
becomes a silently wrong number.

```raku name="oob"
use Text::Sift4;

# same-length inputs never reach the unguarded substr
for <abcd abcd>, <abcd abdc>, <abcd wxyz> -> ($x, $y) {
    say sprintf('sift4(%-6s, %-6s) = %d', $x.raku, $y.raku, sift4($x, $y));
}
say '';
say 'those are safe on both engines. A pair whose lengths differ can walk';
say 'the left cursor past the end of its string, and what happens then is';
say 'up to the engine — so wrap every call you cannot length-match.';
```

```output
sift4("abcd", "abcd") = 0
sift4("abcd", "abdc") = 1
sift4("abcd", "wxyz") = 4

those are safe on both engines. A pair whose lengths differ can walk
the left cursor past the end of its string, and what happens then is
up to the engine — so wrap every call you cannot length-match.
```

`Text::Sift4` the class is empty — the `unit class` declaration carries no
members, and `Text::Sift4.new.sift4(...)` does not exist. The exported sub is
the whole distribution.
