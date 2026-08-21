#!/usr/bin/env rakupp
# Statistics::Distributions — Mixtures and products
# https://raku.online/ecosystem/statistics-distributions/#mixtures-and-products
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 11-product.raku
#
# Run under Raku++ 3.5.1 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

# One draw = one (x, y) pair, x normal and y exponential, independent.
my $pair = ProductDistribution.new(
    NormalDistribution.new(0, 1),
    ExponentialDistribution.new(1),
);

my @pairs = random-variate($pair, 4);
say @pairs.elems;
say @pairs[0].elems;
say so @pairs.map(*.[1]).all >= 0;     # the exponential half is never negative

# Output:
#     4
#     2
#     True
