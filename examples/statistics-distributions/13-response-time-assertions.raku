#!/usr/bin/env rakupp
# Statistics::Distributions — A worked example: a day of response times
# https://raku.online/modules/statistics-distributions/#a-worked-example-a-day-of-response-times
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 13-response-time-assertions.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

my @ms = random-variate(GammaDistribution.new(2, 40), 5000);
my ($p50, $p95, $p99) = quantile(@ms, [0.5, 0.95, 0.99]);

say $p50 < $p95 < $p99;          # quantiles come out in order
say @ms.min >= 0;                # a gamma variate is never negative
say 50 < $p50 < 120;             # the median sits near shape × scale

# Output:
#     True
#     True
#     True
