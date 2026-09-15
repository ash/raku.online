#!/usr/bin/env rakupp
# Text::Sift4 — The one thing to know
# https://raku.online/modules/text-sift4/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::Sift4
#     rakupp 03-asymmetry.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     sift4("ab","bab") = 2   sift4("bab","ab") = 1   (true distance 1)
#     sift4("ac","cac") = 2   sift4("cac","ac") = 1   (true distance 1)
#     sift4("ba","aba") = 2   sift4("aba","ba") = 1   (true distance 1)
#     
#     every mental model of "string distance" assumes d(a,b) == d(b,a).
#     456 of the 14641 short pairs over {a,b,c} violate it here.
#     anything that memoises on a sorted key, dedupes a pair, or builds a
#     symmetric similarity matrix gets a different answer depending on
#     which cell it happened to compute.
