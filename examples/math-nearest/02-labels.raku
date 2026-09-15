#!/usr/bin/env rakupp
# Math::Nearest — Building a finder and asking it
# https://raku.online/modules/math-nearest/#building-a-finder-and-asking-it
#
# Install what it needs, then run it:
#     rakupp install Math::Nearest
#     rakupp 02-labels.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Nearest;

my @places = 'origin' => [0,0], 'east' => [1,0],
             'north'  => [0,1], 'far'  => [5,5];

my &find = nearest(@places);
say &find([1,1], 2).map({ '(' ~ .join(',') ~ ')' }).join(' ');
say &find([1,1], 2, :prop<label>).map(*.head).join(' ');
say nearest(@places, :method<Scan>)([1,1], 2, :prop<label>).map(*.head).join(' ');

# Output:
#     (1,0) (0,1)
#     east north
#     east north
