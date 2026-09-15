---
name: Geo::Location
version: 0.0.4
auth: zef:tbrowder
kind: Distribution · geography
summary: A place as decimal degrees, as `N30d21m22s`, or in the compact
  rise/set form — and supplying only one coordinate relocates you to Florida.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: JSON::Fast
raku-land: https://raku.land/zef:tbrowder/Geo::Location
source: https://github.com/tbrowder/Geo-Location.git
---

## What it is for

Astronomy tools each want coordinates in their own spelling. `Geo::Location`
holds a latitude and longitude plus eleven descriptive fields and renders them
three ways: decimal, degrees/minutes/seconds, and the compact `30N21 87W10`
form that the Astro::Montenbruck rise/set scripts expect.

## Building and rendering

```raku name="basics"
use Geo::Location;

my $g = Geo::Location.new(lat => 51.4775, lon => -0.0014, name => 'Greenwich');

say 'name              : ', $g.name;
say 'lat / lon         : ', $g.lat, ' / ', $g.lon;
say '';
say 'location()        : ', $g.location;
say 'location(:bare)   : ', $g.location(:bare);
say 'dms               : ', $g.location(format => 'dms');
say 'dms, bare         : ', $g.location(format => 'dms', :bare);
say 'rst               : ', $g.location(format => 'rst');
say 'riseset-format    : ', $g.riseset-format;
say '';
say ':format is matched with /:i ^dms/, /:i ^dec/ and /:i ^rst/ —';
say 'anything else falls back to decimal without complaint:';
say '  format => "nonsense" -> ', $g.location(format => 'nonsense');
```

```output
name              : Greenwich
lat / lon         : 51.4775 / -0.0014

location()        : lat: 51.4775, lon: -0.0014
location(:bare)   : 51.4775 -0.0014
dms               : lat: N51d29m-21s, lon: W0d0m5s
dms, bare         : N51d29m-21s W0d0m5s
rst               : lat: 51N29, lon: 0W0
riseset-format    : 51N29 0W0

:format is matched with /:i ^dms/, /:i ^dec/ and /:i ^rst/ —
anything else falls back to decimal without complaint:
  format => "nonsense" -> lat: 51.4775, lon: -0.0014
```

## From JSON, or from the environment

```raku name="sources"
use Geo::Location;

my $j = Geo::Location.new(json => '{"lat":51.5,"lon":-0.125,"name":"Somewhere","id":7}');
say 'from JSON  : ', $j.lat, ', ', $j.lon, '  name=', $j.name, ' id=', $j.id;
say '  lat type : ', $j.lat.WHAT.^name;
say '';
say 'an unknown key is a hard die — the only strictness in the module,';
say 'and it is aimed at the safest input:';
my $r = try Geo::Location.new(json => '{"lat":1,"lon":2,"altitude":9}');
say '  {"altitude":9} -> ', $! ?? $!.message.lines.grep(*.trim).tail.trim !! 'accepted';
say '';
say 'GEO_LOCATION is read when it contains both "lat(" and "lon(" and is';
say 'longer than 12 characters — and leaves lat/lon as Str, not numbers.';
say 'JSON leaves them Rat. Downstream numeric code sees different types';
say 'depending on how the object was made.';
```

```output
from JSON  : 51.5, -0.125  name=Somewhere id=7
  lat type : Rat

an unknown key is a hard die — the only strictness in the module,
and it is aimed at the safest input:
  {"altitude":9} -> FATAL: Unknown attribute 'altitude'

GEO_LOCATION is read when it contains both "lat(" and "lon(" and is
longer than 12 characters — and leaves lat/lon as Str, not numbers.
JSON leaves them Rat. Downstream numeric code sees different types
depending on how the object was made.
```

## The one thing to know

Supplying only one coordinate silently discards it and substitutes the
author's home town.

```raku name="one-coordinate"
use Geo::Location;

my $half = Geo::Location.new(lat => 10);
say 'Geo::Location.new(lat => 10):';
say '  lat  : ', $half.lat;
say '  lon  : ', $half.lon;
say '  name : ', $half.name;
say '';
say 'TWEAK`s first branch fires only when BOTH are defined. A single';
say 'coordinate falls through to the defaults branch, which OVERWRITES';
say 'the one you gave. So the most likely typo in a geolocation program —';
say 'forgetting one number, or misspelling one named argument — does not';
say 'raise, does not warn, and quietly relocates you.';
say '';
say 'require both yourself:';
sub at(:$lat!, :$lon!, *%rest) { Geo::Location.new(:$lat, :$lon, |%rest) }
my $ok = at(lat => 51.4775, lon => -0.0014, name => 'Greenwich');
say '  at(:lat, :lon) -> ', $ok.location(:bare);
my $bad = try at(lat => 10);
say '  at(:lat) alone -> ', $! ?? 'refused' !! 'accepted';
```

```output
Geo::Location.new(lat => 10):
  lat  : 30.35616
  lon  : -87.17095
  name : Gulf Breeze, FL, USA

TWEAK`s first branch fires only when BOTH are defined. A single
coordinate falls through to the defaults branch, which OVERWRITES
the one you gave. So the most likely typo in a geolocation program —
forgetting one number, or misspelling one named argument — does not
raise, does not warn, and quietly relocates you.

require both yourself:
  at(:lat, :lon) -> 51.4775 -0.0014
  at(:lat) alone -> refused
```

## No validation, and rounded seconds

```raku name="validation"
use Geo::Location;

my $wild = Geo::Location.new(lat => 999, lon => -4000);
say 'lat => 999, lon => -4000 is accepted : ', $wild.location(:bare);
say '  and rendered : ', $wild.location(format => 'dms', :bare);
say '';
say 'the private !check-lat-lon exists, its body is comments, and TWEAK';
say 'has a bare `return;` on the line BEFORE the call — dead code.';
say '';
say 'the dms renderer ROUNDS minutes instead of truncating, so seconds';
say 'can come out negative, and minutes can come out as 60:';
for 30.361666666, 1.9999 -> $lat {
    my $g = Geo::Location.new(:$lat, lon => 0);
    say sprintf('  lat %-14s -> %-14s  rst %s',
                $lat, $g.lat-dms, $g.lat-rst);
}
say '';
say 'riseset-format shares that rounding, so the rise/set string is off';
say 'by up to half a minute of arc and can read …N60.';
```

```output
lat => 999, lon => -4000 is accepted : 999 -4000
  and rendered : N999d0m0s W4000d0m0s

the private !check-lat-lon exists, its body is comments, and TWEAK
has a bare `return;` on the line BEFORE the call — dead code.

the dms renderer ROUNDS minutes instead of truncating, so seconds
can come out negative, and minutes can come out as 60:
  lat 30.361666666   -> N30d22m-18s     rst 30N22
  lat 1.9999         -> N1d60m0s        rst 1N60

riseset-format shares that rounding, so the rise/set string is off
by up to half a minute of arc and can read …N60.
```

## Where the two engines differ

One case, and only for an object that was never given coordinates: a JSON
object that omits `lat`/`lon` builds with `lat = Any`, and `lat-dms` then
returns `N0d0m0s` under Raku++ and dies with `No such method 'truncate' for
invocant of type 'Any'` under Rakudo.

```raku name="portable"
use Geo::Location;

# check before you render, and both engines agree
my $j = Geo::Location.new(json => '{"name":"nowhere"}');
say 'a JSON object with no coordinates:';
say '  lat defined ? ', $j.lat.defined;
say '  safe to render ? ', ($j.lat.defined && $j.lon.defined);
say '';
say 'and two subs that are NOT imported by a plain `use`:';
say '  convert-lat and convert-lon need `use Geo::Location :convert-lat,';
say '  :convert-lon` — and both are empty stubs that always return Nil,';
say '  so there is no reason to import them.';
```

```output
a JSON object with no coordinates:
  lat defined ? False
  safe to render ? False

and two subs that are NOT imported by a plain `use`:
  convert-lat and convert-lon need `use Geo::Location :convert-lat,
  :convert-lon` — and both are empty stubs that always return Nil,
  so there is no reason to import them.
```
