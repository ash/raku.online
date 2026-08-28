#!/usr/bin/env rakupp
# Statistics::Distributions — Reading quantiles off data you already have
# https://raku.online/modules/statistics-distributions/#reading-quantiles-off-data-you-already-have
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 09-quantiles.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

my @data = 1 .. 100;

say quantile(@data);                        # the quartiles, by default
say quantile(@data, [0.05, 0.5, 0.95]);
say quantile(@data, :pairs);

# Output:
#     [26 51 76]
#     [6 51 96]
#     [0.25 => 26 0.5 => 51 0.75 => 76]
