#!/usr/bin/env rakupp
# Data::Transformers — Padding and centring
# https://raku.online/modules/data-transformers/#padding-and-centring
#
# Install what it needs, then run it:
#     rakupp install Data::Transformers
#     rakupp 02-arrays.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Transformers::Arrays;

my @a = 1, 2, 3;
say 'array-pad(@a, 6).elems    : ', array-pad(@a, 6).elems;
say 'center-array(@a, 6).elems : ', center-array(@a, 6).elems;
say 'center-array(@a, 6)       : ', center-array(@a, 6).List.raku;
say 'center-array(@a, 9)       : ', center-array(@a, 9).List.raku;

# Output:
#     array-pad(@a, 6).elems    : 15
#     center-array(@a, 6).elems : 6
#     center-array(@a, 6)       : (0, 1, 2, 3, 0, 0)
#     center-array(@a, 9)       : (0, 0, 0, 1, 2, 3, 0, 0, 0)
