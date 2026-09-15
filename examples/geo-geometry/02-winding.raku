#!/usr/bin/env rakupp
# Geo::Geometry — The one thing to know
# https://raku.online/modules/geo-geometry/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Geo::Geometry
#     rakupp 02-winding.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Geometry;

sub twice-area(@p) {
    (^(@p - 1)).map({ @p[$_].x * @p[$_ + 1].y - @p[$_ + 1].x * @p[$_].y }).sum
}

my @ccw = <0 0  4 0  0 3  0 0>.rotor(2).map({ Point.new(.[0], .[1]) });
my @cw  = @ccw.reverse;

say 'counter-clockwise: 2A = ', twice-area(@ccw), '  winding = ', LinearRing.new(points => @ccw).winding;
say 'clockwise        : 2A = ', twice-area(@cw),  '  winding = ', LinearRing.new(points => @cw).winding;

# Output:
#     counter-clockwise: 2A = 12  winding = -1
#     clockwise        : 2A = -12  winding = 1
