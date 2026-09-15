#!/usr/bin/env rakupp
# Data::Transformers — Accumulating and rescaling
# https://raku.online/modules/data-transformers/#accumulating-and-rescaling
#
# Install what it needs, then run it:
#     rakupp install Data::Transformers
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Transformers;
use Data::Transformers::Rescale;

my @sales = 10, 5, 20, 5;
say 'accumulate             : ', accumulate(@sales).List.raku;
say 'the input is unchanged : ', @sales.List.raku;
say '';
say 'rescale a scalar into 0..1 : ', rescale(5, (0, 20), (0, 1));
say 'rescale a list, defaults   : ', rescale([2, 4, 6, 8]).List.raku;
say 'rescale a list to 0..100   : ', rescale([2, 4, 6, 8], (2, 8), (0, 100)).List.raku;

# Output:
#     accumulate             : (10, 15, 35, 40)
#     the input is unchanged : (10, 5, 20, 5)
#     
#     rescale a scalar into 0..1 : 0.25
#     rescale a list, defaults   : (0.0, <1/3>, <2/3>, 1.0)
#     rescale a list to 0..100   : (0.0, <100/3>, <200/3>, 100.0)
