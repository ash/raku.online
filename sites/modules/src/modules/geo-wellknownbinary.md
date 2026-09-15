---
name: Geo::WellKnownBinary
version: 0.1.6
auth: zef:kjpye
kind: Distribution · geospatial
summary: Decode OGC Well-Known Binary — the packed byte format PostGIS keeps
  geometry in — into Geo::Geometry objects, in either byte order and every
  Z/M/ZM variant.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: Geo::Geometry
raku-land: https://raku.land/zef:kjpye/Geo::WellKnownBinary
source: https://github.com/kjpye/Geo-WellKnownBinary.git
---

## What it is for

A geometry column in PostGIS comes back as a packed byte string: a byte-order
flag, a `uint32` type code, and then coordinates as IEEE-754 doubles. That is
Well-Known Binary, and reading it by hand means getting the endianness, the
type-code arithmetic and the nesting right.

This distribution reads it. It is decode-only — there is no encoder here — and
it hands back the objects from `Geo::Geometry`, so you need that installed and
usually `use`d to name the types.

## Decoding a point

```raku name="point"
use Geo::WellKnownBinary;

sub hex(Buf $b) { $b.list.map({ .fmt('%02X') }).join(' ') }

# POINT(1 2), little-endian: 01 | 01000000 | 1.0 | 2.0
my $le = Buf.new(0x01,
                 0x01,0x00,0x00,0x00,
                 0x00,0x00,0x00,0x00,0x00,0x00,0xF0,0x3F,
                 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40);

# the same point, big-endian
my $be = Buf.new(0x00,
                 0x00,0x00,0x00,0x01,
                 0x3F,0xF0,0x00,0x00,0x00,0x00,0x00,0x00,
                 0x40,0x00,0x00,0x00,0x00,0x00,0x00,0x00);

my $p = from-wkb($le);
my $q = from-wkb($be);
say 'little-endian bytes : ', hex($le);
say '  type : ', $p.^name, '   x=', $p.x, ' y=', $p.y;
say 'big-endian bytes    : ', hex($be);
say '  type : ', $q.^name, '   x=', $q.x, ' y=', $q.y;
say 'the two agree       : ', ($p.x == $q.x && $p.y == $q.y);
```

```output
little-endian bytes : 01 01 00 00 00 00 00 00 00 00 00 F0 3F 00 00 00 00 00 00 00 40
  type : Point   x=1 y=2
big-endian bytes    : 00 00 00 00 01 3F F0 00 00 00 00 00 00 40 00 00 00 00 00 00 00
  type : Point   x=1 y=2
the two agree       : True
```

That matches the published layout exactly, and the two byte orders agree.

## Lines and polygons

```raku name="shapes"
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
```

```output
type   : LineString
points : (1,2) (3,4)
type   : Polygon
rings  : 1
ring 0 : (0,0) (1,0) (1,1) (0,0)
```

The type codes follow the OGC numbering, and the Z, M and ZM variants of every
type are handled by the same dispatch.

## The one thing to know

The byte-order flag is not validated, and trailing bytes are ignored.

```raku name="lenient"
use Geo::WellKnownBinary;

# the spec allows only 0 (big) and 1 (little); this says 0x42
my $odd = Buf.new(0x42, 0x01,0x00,0x00,0x00,
                  0,0,0,0,0,0,0xF0,0x3F, 0,0,0,0,0,0,0,0x40);
my $r = from-wkb($odd);
say 'byte-order flag 0x42 : ', $r.^name, ' x=', $r.x, ' y=', $r.y;

# four bytes of junk after a complete point
my $extra = Buf.new(0x01, 0x01,0x00,0x00,0x00,
                    0,0,0,0,0,0,0xF0,0x3F, 0,0,0,0,0,0,0,0x40,
                    0xDE,0xAD,0xBE,0xEF);
my $s = from-wkb($extra);
say 'four junk bytes after : ', $s.^name, ' x=', $s.x, ' y=', $s.y;
```

```output
byte-order flag 0x42 : Point x=1 y=2
four junk bytes after : Point x=1 y=2
```

The code reads the flag as `$buff[$offset++] ?? wkbNDR !! wkbXDR`, so *any*
non-zero byte means little-endian. A corrupt first byte is silently accepted
rather than rejected, and there is no "I consumed exactly the buffer" check
that works — the module's own `fail "from-wkb: buffer too short"` runs after
the reads that would already have thrown.

If the bytes come from anywhere you do not control, check the first byte is 0
or 1 yourself, and compare the geometry's expected size against the buffer
length.

## Where the two engines differ

On what a truncated buffer throws, and it changes what a `CATCH` can match.

```raku name="truncated"
use Geo::WellKnownBinary;

for 'empty', Buf.new,
    'flag only', Buf.new(0x01),
    'half a point', Buf.new(0x01, 0x01,0,0,0, 0,0,0,0) -> $label, $b {
    my $r = try from-wkb($b);
    say sprintf('%-14s -> %s', $label, $! ?? 'threw' !! $r.^name);
}
say '';
say 'an unrecognised type code is the one case both engines agree on:';
my $bad = Buf.new(0x01, 0x63,0x00,0x00,0x00, 0,0,0,0,0,0,0xF0,0x3F, 0,0,0,0,0,0,0,0x40);
my $r = try from-wkb($bad);
say '  ', $! ?? $!.message !! 'no error';
```

```output
empty          -> threw
flag only      -> threw
half a point   -> threw

an unrecognised type code is the one case both engines agree on:
  Can't handle geometry type 99 in from-wkb
```

Raku++ raises a typed `X::OutOfRange` reading `read past end of buffer`;
Rakudo raises an `X::AdHoc` carrying the raw virtual-machine message
`MVMArray: read_buf out of bounds offset 5 start 0 elems 9 count 8`. So
`CATCH { when X::OutOfRange {…} }` around `from-wkb` works on one engine and
not the other. Catch broadly, or check the length before you decode.

The unrecognised-type case is the only path where the module's own
`Failure`-returning contract applies, and it behaves the same on both.

Reading the source, the `MultiPoint` branches pass their points under a
`polygons =>` named argument and the ZM branch calls a `newZM` constructor;
those look like copy-paste slips, but no MultiPoint fixture was built here so
that is a place to look rather than a claim.
