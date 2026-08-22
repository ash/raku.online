#!/usr/bin/env rakupp
# Statistics::Distributions — Discrete draws
# https://raku.online/ecosystem/statistics-distributions/#discrete-draws
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 07-biased-coin.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

# A coin that comes up heads 30% of the time, thrown 10,000 times.
my @throws = random-variate(BernoulliDistribution.new(0.3), 10_000);
my $heads  = @throws.grep(1).elems;

say @throws.unique.sort;                 # only ever 0 or 1
say 0.28 < $heads / @throws.elems < 0.32;

# Output:
#     (0 1)
#     True
