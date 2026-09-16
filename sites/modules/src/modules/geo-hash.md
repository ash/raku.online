---
name: Geo::Hash
version: 0.0.3
auth: cpan:TITSUKI
kind: Distribution · geo
summary: Encodes a latitude and longitude into a geohash string and decodes one
  back, over a bundled C library — three subs, and the prefix property that makes
  the format worth using at all.
status: full
suite: 1 file, green
tested: 2026-09-16
license: BSD-3-Clause
depends: none beyond the core (it builds and bundles libgeohash)
raku-land: https://raku.land/cpan:TITSUKI/Geo::Hash
source: https://github.com/titsuki/raku-Geo-Hash
---

## What it is for

A geohash turns a point on the globe into a short string. The longer the string,
the smaller the box it names — and, crucially, two nearby points share a prefix.
That is what makes the format useful: a proximity test becomes a string
comparison, and a database index over the strings becomes a spatial index.

This distribution exposes three subs over a bundled copy of libgeohash. There is
no object to construct and nothing to configure.

## Encoding and decoding

```raku name="geohash-roundtrip"
use Geo::Hash;

# Tokyo Station, to eight characters
my $hash = geo-encode(35.6812e0, 139.7671e0, 8);
say $hash;

# …and back. Decoding returns a Coord, not a pair of numbers.
my $c = geo-decode($hash);
say $c.latitude.round(0.0001);
say $c.longitude.round(0.0001);
```

```output
xn76urx6
35.6813
139.7672
```

The round trip does not return what you put in, and it is not meant to. A
geohash names a *box*, so decoding gives you a point inside the box the original
coordinates fell into — here about eleven metres from Tokyo Station, which is
what eight characters buys.

Note the `e0` on the arguments. `geo-encode` is declared `Num $lat, Num $lng`,
and a bare `35.6812` is a `Rat`: passing one is a type error rather than a
silent coercion. Write the literals with an exponent, or call `.Num` yourself.

## Precision is the length of the string

Each character narrows the box, alternating between longitude and latitude, so
the height falls by a factor of eight for every two characters:

```raku name="geohash-precision"
use Geo::Hash;

for 1, 3, 5, 7 -> $p {
    my $h = geo-encode(35.6812e0, 139.7671e0, $p);
    my $c = geo-decode($h);
    say $h.fmt('%-8s'), ' ', ($c.north - $c.south).round(0.000001), '° tall';
}
```

```output
x        45° tall
xn7      1.40625° tall
xn76u    0.043945° tall
xn76urx  0.001373° tall
```

`Geo::Hash::Coord` carries six accessors — `latitude`, `longitude`, and the
`north`, `south`, `east`, `west` edges of the box — all `num64`. The edges are
what you want for anything that has to know how coarse the answer is.

## The prefix property

```raku name="geohash-prefix"
use Geo::Hash;

my @hashes = (4, 6, 8).map: { geo-encode(35.6812e0, 139.7671e0, $_) };
say @hashes.join(' ');
say @hashes[2].starts-with(@hashes[0]);
```

```output
xn76 xn76ur xn76urx6
True
```

A shorter hash for the same point is a prefix of a longer one. Two points in the
same `xn76` box agree on four characters whatever precision you stored them at,
so `LIKE 'xn76%'` is a bounding-box query and `.starts-with` is a proximity
test. The caveat every geohash user learns eventually: the converse does not
hold. Two points can be metres apart and share nothing, because a cell boundary
runs between them — the Greenwich meridian and the equator are the worst of
these. If you need neighbours rather than a containment test, that is what
`geo-neighbors` is for; it returns the eight surrounding cells at the same
precision.

## Where the two engines differ

Nowhere in this distribution's own results: the hashes, the decoded
coordinates and the box edges are identical on Raku++ and Rakudo, and the test
file passes on both.

One difference in the surrounding language is worth knowing if you format these
numbers, because it will show up the moment you reach for `printf`. The two
engines round a tie differently:

```raku fragment
printf("%.4f\n", 1.40625e0);   # Raku++ 1.4062   ·  Rakudo 1.4063
printf("%.2f\n", 2.675e0);     # Raku++ 2.67     ·  Rakudo 2.68
```

Raku++ rounds half to even, as C's `printf` does; Rakudo rounds half away from
zero. The first line is a genuine tie — `1.40625` is exactly representable, and
it is exactly the height of an `xn7` box — so either answer is defensible. The
second is not a tie at all: `2.675` is stored as `2.67499999…`, so `2.67` is the
correctly rounded result and `2.68` is not.

The practical advice is the same either way: round with `.round` before you
format, rather than leaving the tie to `printf`.
