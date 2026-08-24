#!/usr/bin/env rakupp
# Statistics::Distributions — A worked example: a day of response times
# https://raku.online/ecosystem/statistics-distributions/#a-worked-example-a-day-of-response-times
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 12-response-times.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

# A day of response times: mostly fast, with a long tail.
my @ms = random-variate(GammaDistribution.new(2, 40), 5000);
my ($p50, $p95, $p99) = quantile(@ms, [0.5, 0.95, 0.99]);

say "p50  {$p50.fmt('%6.1f')} ms";
say "p95  {$p95.fmt('%6.1f')} ms";
say "p99  {$p99.fmt('%6.1f')} ms";

# One run printed:
#     p50    68.2 ms
#     p95   192.0 ms
#     p99   268.6 ms
