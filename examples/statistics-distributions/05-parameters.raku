#!/usr/bin/env rakupp
# Statistics::Distributions — Naming the parameters
# https://raku.online/modules/statistics-distributions/#naming-the-parameters
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 05-parameters.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

say NormalDistribution.new(:mean(170), :sd(8)).Hash;
say NormalDistribution.new(:µ(170), :σ(8)).Hash;
say NormalDistribution.new(170, 8).Hash;

# Output:
#     {class => Normal, mean => 170, sd => 8}
#     {class => Normal, mean => 170, sd => 8}
#     {class => Normal, mean => 170, sd => 8}
