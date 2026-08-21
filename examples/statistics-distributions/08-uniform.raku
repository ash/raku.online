#!/usr/bin/env rakupp
# Statistics::Distributions — Uniform, and the range it draws from
# https://raku.online/ecosystem/statistics-distributions/#uniform-and-the-range-it-draws-from
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 08-uniform.raku
#
# Run under Raku++ 3.5.1 (dev build) and Rakudo 2026.06 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

my @u = random-variate(UniformDistribution.new(-1, 1), 500);
say @u.elems;
say so @u.all ~~ -1 .. 1;
say -0.2 < @u.sum / @u.elems < 0.2;

# Output:
#     500
#     True
#     True
