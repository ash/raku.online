#!/usr/bin/env rakupp
# Math::DistanceFunctions::Native — Identical vectors
# https://raku.online/modules/math-distancefunctions-native/#identical-vectors
#
# Install what it needs, then run it:
#     rakupp install Math::DistanceFunctions::Native
#     rakupp 02-identical.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::DistanceFunctions::Native;

my @a = [1e0, 2e0, 3e0];
say 'euclidean(a, a) : ', euclidean-distance(@a, @a);
say 'cosine(a, a)    : ', cosine-distance(@a, @a);
say 'dot(a, a)       : ', dot-product(@a, @a);
say 'norm(a) squared : ', norm(@a) ** 2;

# Output:
#     euclidean(a, a) : 0
#     cosine(a, a)    : 0
#     dot(a, a)       : 14
#     norm(a) squared : 14
