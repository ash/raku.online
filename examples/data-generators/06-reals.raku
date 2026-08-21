#!/usr/bin/env rakupp
# Data::Generators — Numbers and date-times
# https://raku.online/ecosystem/data-generators/#numbers-and-date-times
#
# Install what it needs, then run it:
#     rakupp install Data::Generators
#     rakupp 06-reals.raku
#
# Run under Raku++ 3.5.1 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use Data::Generators;

my @r = random-real((10, 20), 1000);
say @r.elems;
say so @r.all ~~ Num;
say so ([&&] @r.map({ 10 <= $_ <= 20 }));
say 14 < @r.sum / @r.elems < 16;

# Output:
#     1000
#     True
#     True
#     True
