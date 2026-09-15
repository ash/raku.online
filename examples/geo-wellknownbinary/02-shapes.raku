#!/usr/bin/env rakupp
# Geo::WellKnownBinary — Lines and polygons
# https://raku.online/modules/geo-wellknownbinary/#lines-and-polygons
#
# Install what it needs, then run it:
#     rakupp install Geo::WellKnownBinary
#     rakupp 02-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::WellKnownBinary;

# LINESTRING(1 2, 3 4)
my $ls = Buf.new(0x01,
                 0x02,0x00,0x00,0x00,
                 0x02,0x00,0x00,0x00,
                 0x00,0x00,0x00,0x00,0x00,0x00,0xF0,0x3F,
                 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,
                 0x00,0x00,0x00,0x00,0x00,0x00,0x08,0x40,
                 0x00,0x00,0x00,0x00,0x00,0x00,0x10,0x40);
my $g = from-wkb($ls);
say 'type   : ', $g.^name;
say 'points : ', $g.points.map({ "({.x},{.y})" }).join(' ');

# POLYGON((0 0, 1 0, 1 1, 0 0)) — one ring of four points
my $poly = Buf.new(0x01, 0x03,0x00,0x00,0x00, 0x01,0x00,0x00,0x00, 0x04,0x00,0x00,0x00);
for (0e0,0e0), (1e0,0e0), (1e0,1e0), (0e0,0e0) -> ($x, $y) {
    $poly.append(Buf.new.write-num64(0, $x, LittleEndian));
    $poly.append(Buf.new.write-num64(0, $y, LittleEndian));
}
my $pg = from-wkb($poly);
say 'type   : ', $pg.^name;
say 'rings  : ', $pg.rings.elems;
say 'ring 0 : ', $pg.rings[0].points.map({ "({.x},{.y})" }).join(' ');

# Output:
#     type   : LineString
#     points : (1,2) (3,4)
#     type   : Polygon
#     rings  : 1
#     ring 0 : (0,0) (1,0) (1,1) (0,0)
