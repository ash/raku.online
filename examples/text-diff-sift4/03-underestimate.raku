#!/usr/bin/env rakupp
# Text::Diff::Sift4 — The one thing to know
# https://raku.online/modules/text-diff-sift4/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::Diff::Sift4
#     rakupp 03-underestimate.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     kitten         sitting        sift4=3  levenshtein=3  agree
#     flaw           lawn           sift4=1  levenshtein=2  UNDERESTIMATES
#     banana         ananas         sift4=1  levenshtein=2  UNDERESTIMATES
#     abcd           dcba           sift4=3  levenshtein=4  UNDERESTIMATES
#     xyzabcdefghij  abcdefghijxyz  sift4=3  levenshtein=6  UNDERESTIMATES
