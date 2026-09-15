#!/usr/bin/env rakupp
# Math::DistanceFunctions — Ten kernels
# https://raku.online/modules/math-distancefunctions/#ten-kernels
#
# Install what it needs, then run it:
#     rakupp install Math::DistanceFunctions
#     rakupp 01-kernels.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::DistanceFunctions;

my @a = 1, 2, 3;
my @b = 4, 6, 8;

say 'euclidean   ', euclidean-distance(@a, @b);
say 'sq-euclid   ', squared-euclidean-distance(@a, @b);
say 'manhattan   ', manhattan-distance(@a, @b);
say 'chessboard  ', chessboard-distance(@a, @b);
say 'cosine      ', cosine-distance(@a, @b);
say 'bray-curtis ', bray-curtis-distance(@a, @b);
say 'hamming     ', hamming-distance(@a, @b);
say 'dot product ', dot-product(@a, @b);
say 'norm p=1    ', norm(@a, 1);
say 'norm p=2    ', norm(@a);
say 'self        ', euclidean-distance(@a, @a), ' ', cosine-distance(@a, @a);

# Output:
#     euclidean   7.0710678118654755
#     sq-euclid   50
#     manhattan   12
#     chessboard  5
#     cosine      0.007416666029069652
#     bray-curtis 0.5
#     hamming     3
#     dot product 40
#     norm p=1    6
#     norm p=2    3.7416573867739413
#     self        0 0
