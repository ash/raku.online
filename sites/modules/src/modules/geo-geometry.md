---
name: Geo::Geometry
version: 0.1.3
auth: zef:kjpye
kind: Distribution · graphics
summary: The OGC simple-feature shapes as Raku classes — points, lines,
  rings, polygons and the collections — each able to serialise itself to
  standard binary WKB.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:kjpye/Geo::Geometry
source: https://github.com/kjpye/Raku-Geo-Geometry
---

## What it is for

Geographic data has a standard type system — the Open Geospatial
Consortium's simple features — and it is the vocabulary PostGIS, GDAL,
GeoJSON and every spatial database speak: Point, LineString, LinearRing,
Polygon, the four Multi-something collections, and a GeometryCollection to
hold a mixture. Each comes in four flavours, with an elevation, with a
measure, with both, or with neither.

This distribution is those classes, forty-four of them, each carrying its
OGC type code and able to write itself out as Well-Known Binary in either
byte order.

## Shapes, and the bytes they become

```raku name="shapes"
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
```

```output
30 10
Point(30 10)
wkbPoint = 1
0000000001403E0000000000004024000000000000
01010000000000000000003E400000000000002440
PointZ(30 10 5) type 1001
3 LineString(30 10,10 30,40 40)
Polygon((0 0,1 0,1 1,0 1,0 0))
MultiPoint((1 2),(3 4))
```

The binary is the standard: `00` for big-endian, then the four-byte type
code, then the coordinates as doubles — and the little-endian form is its
exact mirror. That part interoperates. Every container takes its members as
a named argument (`points`, `rings`, `geometries`); only the `Point` family
has a positional constructor.

## The one thing to know

`.winding` reports the opposite sign to the usual convention:

```raku name="winding"
use Geo::Geometry;

sub twice-area(@p) {
    (^(@p - 1)).map({ @p[$_].x * @p[$_ + 1].y - @p[$_ + 1].x * @p[$_].y }).sum
}

my @ccw = <0 0  4 0  0 3  0 0>.rotor(2).map({ Point.new(.[0], .[1]) });
my @cw  = @ccw.reverse;

say 'counter-clockwise: 2A = ', twice-area(@ccw), '  winding = ', LinearRing.new(points => @ccw).winding;
say 'clockwise        : 2A = ', twice-area(@cw),  '  winding = ', LinearRing.new(points => @cw).winding;
```

```output
counter-clockwise: 2A = 12  winding = -1
clockwise        : 2A = -12  winding = 1
```

The shoelace formula gives a positive signed area for a counter-clockwise
ring, and this method answers −1 for exactly that case. Wire it straight
into an OGC orientation check or a GeoJSON right-hand-rule validator and
every ring comes out backwards. Both engines agree, so it is the module's
convention and not an interpreter difference — just read it as "−1 means
counter-clockwise" and the code is correct.

Two more things before you serialise anything. `.wkt` is **not** standard
Well-Known Text: the real thing is `POINT (30 10)`, and what you get is
`Point(30 10)` — wrong keyword case, no space, and `PointZ` where the
standard writes `POINT Z`. Tools will reject it, and `.wkb` is the
interoperable output. And `LinearRing` has no `.wkt`, `.type` or `.wkb` at
all; only the polygon that contains it does.
