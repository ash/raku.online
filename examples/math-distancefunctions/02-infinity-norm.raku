#!/usr/bin/env rakupp
# Math::DistanceFunctions — The one thing to know
# https://raku.online/modules/math-distancefunctions/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::DistanceFunctions
#     rakupp 02-infinity-norm.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::DistanceFunctions;

say norm([1, 2, 3], 2);
say norm([1, 2, 3], 10);
say norm([1, 2, 3], Inf);
say norm([7, 2], Inf);
say chessboard-distance([0, 0, 0], [1, 2, 3]);

# Output:
#     3.7416573867739413
#     3.005167303445029
#     1
#     1
#     3
