#!/usr/bin/env rakupp
# Geo::Ellipsoid — The one thing to know
# https://raku.online/modules/geo-ellipsoid/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Geo::Ellipsoid
#     rakupp 04-order-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Ellipsoid;

my $geo = Geo::Ellipsoid.new(units => 'degrees');

# Rome is latitude 41.90 N, longitude 12.50 E — both are legal latitudes,
# so nothing can detect the transposition.
my ($a, $b) = $geo.to(41.90, 12.50, 41.91, 12.51);   # lat first: WRONG
my ($c, $d) = $geo.to(12.50, 41.90, 12.51, 41.91);   # lon first: RIGHT

say sprintf('lat-first (wrong) : range=%.3f bearing=%.3f', $a, $b);
say sprintf('lon-first (right) : range=%.3f bearing=%.3f', $c, $d);
say 'the two agree? ', ($a.round(0.001) == $c.round(0.001));
say 'no warning, no exception — both look like plausible answers';

# Output:
#     lat-first (wrong) : range=1386.417 bearing=36.758
#     lon-first (right) : range=1550.901 bearing=44.495
#     the two agree? False
#     no warning, no exception — both look like plausible answers
