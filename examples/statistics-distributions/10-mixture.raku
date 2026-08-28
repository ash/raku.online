#!/usr/bin/env rakupp
# Statistics::Distributions — Mixtures and products
# https://raku.online/modules/statistics-distributions/#mixtures-and-products
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 10-mixture.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

# 30% of the readings come from one process, 70% from another.
my $mix = MixtureDistribution.new(
    [0.3, 0.7],
    [NormalDistribution.new(0, 1), NormalDistribution.new(10, 1)],
);

my @m = random-variate($mix, 2000);
say @m.elems;
say 0.26 < @m.grep(* < 5).elems / @m.elems < 0.34;

# Output:
#     2000
#     True
