---
name: Geo::Ellipsoid
version: 1.0.1
auth: zef:tbrowder
kind: Distribution · geodesy
summary: Solve the two classical geodesy problems on an ellipsoidal Earth —
  distance and bearing between two points, and the point a distance and
  bearing away — over nineteen named reference ellipsoids.
status: full
suite: 11 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:tbrowder/Geo::Ellipsoid
source: git://github.com/tbrowder/Geo-Ellipsoid.git
---

## What it is for

The Earth is not a sphere, and the difference matters as soon as the distances
get long: a great-circle calculation on a sphere is out by several kilometres
across a continent. The ellipsoidal answer needs Vincenty's iterative
formulae, which nobody wants to write twice.

This distribution is a direct port of the Perl 5 module of the same name. It
ships nineteen reference ellipsoids — WGS84, GRS80, NAD27, AIRY and the rest —
accepts a custom one, and reports distances in feet, kilometres, metres, miles
or nautical miles.

## Distance and bearing

```raku name="range"
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
```

```output
ellipsoid  : WGS84
equatorial : 6378137
flattening : 0.003352810665

range (0,0)->(0,1)  : 111319.490793 m
a * pi/180          : 111319.490793 m
agree to 1e-6 m     : True

range (0,0)->(90,0) : 10001965.729 m
published quarter   : 10001965.729 m
agree to 1 mm       : True

bearing (0,0)->(0,1)  : 90.000000 deg
bearing (0,0)->(90,0) : 0.000000 deg
```

Those two checks are the ones worth running against any geodesy library. Both
pass: a degree of equatorial longitude matches the closed form to under a
micrometre, and equator-to-pole matches the published WGS84 quarter meridian
to under a millimetre.

## Going the other way

```raku name="at"
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
```

```output
at (0,0) 111319.49 m due east : lat=0.000000000 lon=1.000000000
to (0,0)->(0,1)               : range=111319.490793 bearing=90.000000
displacement (metres east, north) : 111319.491 0.000
location back from that          : lat=0.000000000 lon=1.000000000
```

`at` inverts `range`/`bearing` exactly, and `location` inverts `displacement`.

## Other units and other ellipsoids

```raku name="units"
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
```

```output
meter      one degree of equatorial longitude = 111319.490793
kilometer  one degree of equatorial longitude = 111.319491
mile       one degree of equatorial longitude = 69.170725
nm         one degree of equatorial longitude = 60.107716
foot       one degree of equatorial longitude = 365221.426487

WGS84  equatorial=6378137    flattening=0.0033528107
GRS80  equatorial=6378137    flattening=0.0033528107
NAD27  equatorial=6378206.4  flattening=0.0033900753
AIRY   equatorial=6377563.396 flattening=0.0033408506

Ellipsoid NOT-AN-ELLIPSOID does not exist - please use set_custom_ellipsoid to use an ellipsoid not in valid set
```

An unknown ellipsoid name and an unknown unit name both die at construction
with a clear message, which is the right time for it.

## The one thing to know

**Longitude comes before latitude**, in every routine, and a swap is silent.

```raku name="order-trap"
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
```

```output
lat-first (wrong) : range=1386.417 bearing=36.758
lon-first (right) : range=1550.901 bearing=44.495
the two agree? False
no warning, no exception — both look like plausible answers
```

Nearly every other geographic interface in circulation reads latitude first,
and so does this distribution's own `Astro::Location`-style accessor ordering.
Here it is `range($lat1, $lon1, $lat2, $lon2)` on the page and `$lon` first in
the code. For any place whose two coordinates are both valid latitudes — which
is everywhere between 90°W and 90°E — the swap produces a confident wrong
answer. You are only caught out loudly if your longitude exceeds 90.

Write a wrapper with named arguments at your own call site.

## Where the two engines differ

Only in the text of one error message, and the message is for a method that
can never succeed anyway.

`to-range` is in the public method list with a `--> Real` signature and dies
every single time it is called, on both engines. Its body assigns the
two-element result of the internal inverse solution to a scalar, and the
`Real` return constraint then rejects the list. `range` is the working method;
`to-range` is a trap with a plausible name. Raku++ reports the rejected value
as `Slip ((111319.49…`, Rakudo as `slip(111319.49…` — a `.gist` difference
inside an error, nothing more.

Two further things, both engine-independent. **The default unit is radians**,
so `Geo::Ellipsoid.new.range(0,0,0,1)` returns 6,378,137 metres — one radian
of longitude — where the same call on a `units => 'degrees'` object returns
111,319. A 57× silent error for anyone who assumes degrees. And
`Geo::Ellipsoid::Utils`'s `lat-hms2deg` requires an explicit hemisphere letter
or sign: `'N12 30 00'` works, `'12 30 00'` dies with `Unexpected error!`, and
so does colon-separated input.
