#!/usr/bin/env rakupp
# Math::DistanceFunctions::Edit — Two subs
# https://raku.online/modules/math-distancefunctions-edit/#two-subs
#
# Install what it needs, then run it:
#     rakupp install Math::DistanceFunctions::Edit
#     rakupp 01-distance.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::DistanceFunctions::Edit;

say edit-distance('kitten', 'sitting');
say edit-distance('abcd', 'acbd');
say edit-distance('', 'abc');
say edit-distance('same', 'same');
say edit-distance('Raku', 'raku');
say edit-distance('Raku', 'raku', :i);
say edit-distance-fast('kitten', 'sitting');
say edit-distance(<a b c>, <a x c>);

# Output:
#     3
#     1
#     3
#     0
#     1
#     0
#     3
#     1
