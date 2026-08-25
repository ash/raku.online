#!/usr/bin/env rakupp
# Statistics::Distributions — Your first draw
# https://raku.online/modules/statistics-distributions/#your-first-draw
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 04-reuse-a-distribution.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

my $noise = NormalDistribution.new(:mean(0), :sd(0.5));

say ($_ + random-variate($noise)).fmt('%.2f') for 1, 2, 3;

# One run printed:
#     1.29
#     1.71
#     3.42
