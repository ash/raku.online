#!/usr/bin/env rakupp
# Statistics::Distributions — Where the two engines differ
# https://raku.online/ecosystem/statistics-distributions/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 14-srand.raku
#
# Run under Raku++ 3.5.1 (dev build) and Rakudo 2026.06 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

srand(42);
my @a = random-variate(NormalDistribution.new(0, 1), 3);
srand(42);
my @b = random-variate(NormalDistribution.new(0, 1), 3);

say @a eqv @b;
