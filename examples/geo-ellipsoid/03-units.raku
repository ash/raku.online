#!/usr/bin/env rakupp
# Geo::Ellipsoid — Other units and other ellipsoids
# https://raku.online/modules/geo-ellipsoid/#other-units-and-other-ellipsoids
#
# Install what it needs, then run it:
#     rakupp install Geo::Ellipsoid
#     rakupp 03-units.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Ellipsoid;

for 'meter', 'kilometer', 'mile', 'nm', 'foot' -> $u {
    my $g = Geo::Ellipsoid.new(units => 'degrees', distance_units => $u);
    say sprintf('%-10s one degree of equatorial longitude = %.6f', $u, $g.range(0,0,0,1));
}
say '';
for 'WGS84', 'GRS80', 'NAD27', 'AIRY' -> $e {
    my $g = Geo::Ellipsoid.new(units => 'degrees', ellipsoid => $e);
    say sprintf('%-6s equatorial=%-10s flattening=%.10f', $e, $g.equatorial, $g.flattening);
}
say '';
say (try Geo::Ellipsoid.new(ellipsoid => 'NOT-AN-ELLIPSOID')) // $!.message;

# Output:
#     meter      one degree of equatorial longitude = 111319.490793
#     kilometer  one degree of equatorial longitude = 111.319491
#     mile       one degree of equatorial longitude = 69.170725
#     nm         one degree of equatorial longitude = 60.107716
#     foot       one degree of equatorial longitude = 365221.426487
#     
#     WGS84  equatorial=6378137    flattening=0.0033528107
#     GRS80  equatorial=6378137    flattening=0.0033528107
#     NAD27  equatorial=6378206.4  flattening=0.0033900753
#     AIRY   equatorial=6377563.396 flattening=0.0033408506
#     
#     Ellipsoid NOT-AN-ELLIPSOID does not exist - please use set_custom_ellipsoid to use an ellipsoid not in valid set
