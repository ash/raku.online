#!/usr/bin/env rakupp
# Text::Diff::Sift4 — Measuring a distance
# https://raku.online/modules/text-diff-sift4/#measuring-a-distance
#
# Install what it needs, then run it:
#     rakupp install Text::Diff::Sift4
#     rakupp 01-sift.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Diff::Sift4;

for <kitten sitting>, <Sift Sifter>, <London Londo>, <abcdefg abcdefg>,
    <a b>, ('Hello World', 'Hello Wolrd') -> ($a, $b) {
    say sprintf('%-12s %-12s -> %d', $a, $b, sift4($a, $b));
}
say sift4('', ''), ' ', sift4('', 'abc'), ' ', sift4('abc', '');

# Output:
#     kitten       sitting      -> 3
#     Sift         Sifter       -> 2
#     London       Londo        -> 1
#     abcdefg      abcdefg      -> 0
#     a            b            -> 1
#     Hello World  Hello Wolrd  -> 1
#     0 3 3
