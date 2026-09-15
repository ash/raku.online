#!/usr/bin/env rakupp
# Geo::Ellipsoid — Distance and bearing
# https://raku.online/modules/geo-ellipsoid/#distance-and-bearing
#
# Install what it needs, then run it:
#     rakupp install Geo::Ellipsoid
#     rakupp 01-range.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Ellipsoid;

my $geo = Geo::Ellipsoid.new(units => 'degrees');

say 'ellipsoid  : ', $geo.ellipsoid;
say 'equatorial : ', $geo.equatorial;
say 'flattening : ', $geo.flattening.fmt('%.12f');
say '';

# one degree of longitude along the equator is a * pi/180
my $eq = $geo.range(0, 0, 0, 1);
say 'range (0,0)->(0,1)  : ', $eq.fmt('%.6f'), ' m';
say 'a * pi/180          : ', (6378137 * pi/180).fmt('%.6f'), ' m';
say 'agree to 1e-6 m     : ', abs($eq - 6378137 * pi/180) < 1e-6;
say '';

# equator to pole is the quarter meridian, published as 10001965.729 m
my $qm = $geo.range(0, 0, 90, 0);
say 'range (0,0)->(90,0) : ', $qm.fmt('%.3f'), ' m';
say 'published quarter   : 10001965.729 m';
say 'agree to 1 mm       : ', abs($qm - 10001965.729) < 0.001;
say '';
say 'bearing (0,0)->(0,1)  : ', $geo.bearing(0, 0, 0, 1).fmt('%.6f'), ' deg';
say 'bearing (0,0)->(90,0) : ', $geo.bearing(0, 0, 90, 0).fmt('%.6f'), ' deg';

# Output:
#     ellipsoid  : WGS84
#     equatorial : 6378137
#     flattening : 0.003352810665
#     
#     range (0,0)->(0,1)  : 111319.490793 m
#     a * pi/180          : 111319.490793 m
#     agree to 1e-6 m     : True
#     
#     range (0,0)->(90,0) : 10001965.729 m
#     published quarter   : 10001965.729 m
#     agree to 1 mm       : True
#     
#     bearing (0,0)->(0,1)  : 90.000000 deg
#     bearing (0,0)->(90,0) : 0.000000 deg
