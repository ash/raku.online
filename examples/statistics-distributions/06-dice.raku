#!/usr/bin/env rakupp
# Statistics::Distributions — Discrete draws
# https://raku.online/ecosystem/statistics-distributions/#discrete-draws
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 06-dice.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

my @rolls = random-variate(DiscreteUniformDistribution.new(1, 6), 6000);
say @rolls.unique.sort;
say so @rolls.all ~~ Int;

my %seen = @rolls.Bag;
say so %seen.values.all ~~ 800..1200;

# Output:
#     (1 2 3 4 5 6)
#     True
#     True
