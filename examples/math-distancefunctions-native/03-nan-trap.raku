#!/usr/bin/env rakupp
# Math::DistanceFunctions::Native — The one thing to know
# https://raku.online/modules/math-distancefunctions-native/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::DistanceFunctions::Native
#     rakupp 03-nan-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::DistanceFunctions::Native;

my @a = [1e0, 2e0, 3e0];
my @zero = [0e0, 0e0, 0e0];

say 'cosine-distance(a, zero)    : ', cosine-distance(@a, @zero);
say 'euclidean-distance(a, zero) : ', euclidean-distance(@a, @zero);
say '';
my $nan = cosine-distance(@a, @zero);
say 'every comparison against it is false:';
say '  NaN < 1  : ', $nan < 1;
say '  NaN > 1  : ', $nan > 1;
say '  NaN == NaN : ', $nan == $nan;
say '';
say 'so in a .sort by cosine distance it lands wherever the sort puts it,';
say 'silently, rather than blowing up.';

# Output:
#     cosine-distance(a, zero)    : NaN
#     euclidean-distance(a, zero) : 3.7416573867739413
#     
#     every comparison against it is false:
#       NaN < 1  : False
#       NaN > 1  : False
#       NaN == NaN : False
#     
#     so in a .sort by cosine distance it lands wherever the sort puts it,
#     silently, rather than blowing up.
