#!/usr/bin/env rakupp
# Math::DistanceFunctions::Native — The distances
# https://raku.online/modules/math-distancefunctions-native/#the-distances
#
# Install what it needs, then run it:
#     rakupp install Math::DistanceFunctions::Native
#     rakupp 01-distances.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::DistanceFunctions::Native;

my @a = [1e0, 2e0, 3e0];
my @b = [4e0, 5e0, 6e0];

say 'euclidean-distance         : ', euclidean-distance(@a, @b);
say 'squared-euclidean-distance : ', squared-euclidean-distance(@a, @b);
say 'dot-product                : ', dot-product(@a, @b);
say 'cosine-distance            : ', cosine-distance(@a, @b);
say 'norm(@a)                   : ', norm(@a);
say '';
say 'checks:';
say '  sqrt(27)          = ', 27.sqrt;
say '  1*4 + 2*5 + 3*6   = ', 1*4 + 2*5 + 3*6;
say '  sqrt(1+4+9)       = ', 14.sqrt;

# Output:
#     euclidean-distance         : 5.196152422706632
#     squared-euclidean-distance : 27
#     dot-product                : 32
#     cosine-distance            : 0.025368153802923787
#     norm(@a)                   : 3.7416573867739413
#     
#     checks:
#       sqrt(27)          = 5.196152422706632
#       1*4 + 2*5 + 3*6   = 32
#       sqrt(1+4+9)       = 3.7416573867739413
