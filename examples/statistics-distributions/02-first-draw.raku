#!/usr/bin/env rakupp
# Statistics::Distributions — Your first draw
# https://raku.online/ecosystem/statistics-distributions/#your-first-draw
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 02-first-draw.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

my @heights = random-variate(NormalDistribution.new(:mean(170), :sd(8)), 5);
say .fmt('%.1f') for @heights;

# One run printed:
#     170.6
#     164.3
#     164.0
#     183.4
#     176.4
