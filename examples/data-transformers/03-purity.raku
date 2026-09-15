#!/usr/bin/env rakupp
# Data::Transformers — Purity
# https://raku.online/modules/data-transformers/#purity
#
# Install what it needs, then run it:
#     rakupp install Data::Transformers
#     rakupp 03-purity.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Transformers;
use Data::Transformers::Arrays;
use Data::Transformers::Rescale;

my @a = 3, 1, 4, 1, 5;
my @snapshot = @a;

accumulate(@a);
array-pad(@a, 2);
center-array(@a, 9);
rescale(@a);

say 'after all four calls, the input is unchanged : ', @a eqv @snapshot;
say '';
my @out = |accumulate(@a);
@out[0] = -1;
say 'and the result is a fresh container:';
say '  input  : ', @a.List.raku;
say '  result : ', @out.List.raku;

# Output:
#     after all four calls, the input is unchanged : True
#     
#     and the result is a fresh container:
#       input  : (3, 1, 4, 1, 5)
#       result : (-1, 4, 8, 9, 14)
