#!/usr/bin/env rakupp
# Geo::Ellipsoid — Going the other way
# https://raku.online/modules/geo-ellipsoid/#going-the-other-way
#
# Install what it needs, then run it:
#     rakupp install Geo::Ellipsoid
#     rakupp 02-at.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Ellipsoid;

my $geo = Geo::Ellipsoid.new(units => 'degrees');

my ($lat, $lon) = $geo.at(0, 0, 111319.490793, 90);
say 'at (0,0) 111319.49 m due east : lat=', $lat.fmt('%.9f'), ' lon=', $lon.fmt('%.9f');

my ($r, $b) = $geo.to(0, 0, 0, 1);
say 'to (0,0)->(0,1)               : range=', $r.fmt('%.6f'), ' bearing=', $b.fmt('%.6f');

my ($x, $y) = $geo.displacement(0, 0, 0, 1);
say 'displacement (metres east, north) : ', $x.fmt('%.3f'), ' ', $y.fmt('%.3f');

my ($la, $lo) = $geo.location(0, 0, 111319.490793, 0);
say 'location back from that          : lat=', $la.fmt('%.9f'), ' lon=', $lo.fmt('%.9f');

# Output:
#     at (0,0) 111319.49 m due east : lat=0.000000000 lon=1.000000000
#     to (0,0)->(0,1)               : range=111319.490793 bearing=90.000000
#     displacement (metres east, north) : 111319.491 0.000
#     location back from that          : lat=0.000000000 lon=1.000000000
