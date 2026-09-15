#!/usr/bin/env rakupp
# Geo::Geometry — Shapes, and the bytes they become
# https://raku.online/modules/geo-geometry/#shapes-and-the-bytes-they-become
#
# Install what it needs, then run it:
#     rakupp install Geo::Geometry
#     rakupp 01-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Geometry;

sub hex($b) { $b.list.map({ .fmt('%02X') }).join }

my $p = Point.new(30, 10);
say $p.Str;
say $p.wkt;
say $p.type, ' = ', +$p.type;
say hex($p.wkb);
say hex($p.wkb(:byteorder(wkbNDR)));

say PointZ.new(30, 10, 5).wkt, ' type ', +PointZ.new(30, 10, 5).type;

my $line = LineString.new(points => [Point.new(30, 10), Point.new(10, 30), Point.new(40, 40)]);
say $line.num-points, ' ', $line.wkt;

my @ring = <0 0  1 0  1 1  0 1  0 0>.rotor(2).map({ Point.new(.[0], .[1]) });
my $poly = Polygon.new(rings => [LinearRing.new(points => @ring)]);
say $poly.wkt;
say MultiPoint.new(points => [Point.new(1, 2), Point.new(3, 4)]).wkt;

# Output:
#     30 10
#     Point(30 10)
#     wkbPoint = 1
#     0000000001403E0000000000004024000000000000
#     01010000000000000000003E400000000000002440
#     PointZ(30 10 5) type 1001
#     3 LineString(30 10,10 30,40 40)
#     Polygon((0 0,1 0,1 1,0 1,0 0))
#     MultiPoint((1 2),(3 4))
