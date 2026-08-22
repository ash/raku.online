#!/usr/bin/env rakupp
# Statistics::Distributions — What it is for
# https://raku.online/ecosystem/statistics-distributions/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 01-catalogue.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

say known-distributions.keys.elems;
say known-distributions.keys.grep(*.starts-with('normal')).sort;
say random-variate('Normal', 3).elems;

# Output:
#     132
#     (normal normal-distribution normal_distribution normaldistribution)
#     3
