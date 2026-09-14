#!/usr/bin/env rakupp
# Text::Levenshtein::Damerau — Two distances and a cut-off
# https://raku.online/modules/text-levenshtein-damerau/#two-distances-and-a-cut-off
#
# Install what it needs, then run it:
#     rakupp install Text::Levenshtein::Damerau
#     rakupp 01-distances.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Levenshtein::Damerau;

say ld('kitten', 'sitting'), ' ', dld('kitten', 'sitting');
say ld('abcd', 'acbd'), ' ', dld('abcd', 'acbd');
say ld('', 'abc'), ' ', dld('same', 'same');
say dld('rakudo', 'raku', 1).defined;

# Output:
#     3 3
#     2 1
#     3 0
#     False
