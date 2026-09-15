#!/usr/bin/env rakupp
# Algorithm::LCS — Finding the subsequence
# https://raku.online/modules/algorithm-lcs/#finding-the-subsequence
#
# Install what it needs, then run it:
#     rakupp install Algorithm::LCS
#     rakupp 01-lcs.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::LCS;

sub show(@a, @b, |c) {
    my @r = lcs(@a, @b, |c);
    sprintf('lcs(%-10s, %-10s) = %-14s len=%d',
        @a.join(''), @b.join(''), '[' ~ @r.join(' ') ~ ']', @r.elems)
}

say show [<X M J Y A U Z>], [<M Z J A W X U>];
say show [<A G C A T>], [<G A C>];
say show 'human'.comb.Array, 'chimpanzee'.comb.Array;
say show [<a b c>], [<a b c>];
say show [<a b c>], [<x y z>];
say show [<A A A>], [<A A>];
say show [1, 2, 3, 4], [2, 4, 5];

# Output:
#     lcs(XMJYAUZ   , MZJAWXU   ) = [M J A U]      len=4
#     lcs(AGCAT     , GAC       ) = [G A]          len=2
#     lcs(human     , chimpanzee) = [h m a n]      len=4
#     lcs(abc       , abc       ) = [a b c]        len=3
#     lcs(abc       , xyz       ) = []             len=0
#     lcs(AAA       , AA        ) = [A A]          len=2
#     lcs(1234      , 245       ) = [2 4]          len=2
