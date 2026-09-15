---
name: Astro::Sunrise
version: 0.0.4
auth: zef:tbrowder
kind: Distribution · astronomy
summary: The local clock times at which the sun's centre crosses a chosen
  altitude on a given date at a given point on the globe.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:tbrowder/Astro::Sunrise
source: https://github.com/tbrowder/Astro-Sunrise.git
---

## What it is for

Anything that schedules around daylight — an irrigation controller, a
photography planner, a lighting timer, a prayer-times application — needs to
know when the sun rises and sets at a place on a date. The almanac arithmetic
behind that is the same everywhere and nobody wants to write it twice.

This distribution is a direct port of the Perl 5 module of the same name.

## Sunrise and sunset

```raku name="sunrise"
use Astro::Sunrise;

# Boston: longitude -71.0589, latitude 42.3601, UTC-5
my $date = Date.new(2024, 6, 21);
my ($rise, $set) = sunrise($date, -71.0589, 42.3601, -5);
say "Boston, midsummer  rise=$rise set=$set";
say 'return types       : ', $rise.^name, ' / ', $set.^name;
say '';
my ($dr, $ds) = sunrise(2024, 6, 21, -71.0589, 42.3601, -5);
say 'the year/month/day form gives DateTimes:';
say '  rise : ', $dr;
say '  set  : ', $ds;
```

```output
Boston, midsummer  rise=04:06 set=19:26
return types       : Str / Str

the year/month/day form gives DateTimes:
  rise : 2024-06-21T04:06:00Z
  set  : 2024-06-21T19:26:00Z
```

There are two candidates. Hand it a `Date` and you get two `"HH:MM"` strings;
hand it a year, a month and a day and you get two `DateTime`s.

## Choosing an altitude

```raku name="altitude"
use Astro::Sunrise;

my $date = Date.new(2024, 6, 21);

for -0.833, -6, -12, -18 -> $alt {
    my ($r, $s) = sunrise($date, -71.0589, 42.3601, -5, $alt);
    say sprintf('altitude %6.3f -> rise=%s set=%s', $alt, $r, $s);
}
say '';
say '-0.833 is the default: the sun\'s upper limb at the horizon,';
say 'allowing for refraction. -6, -12 and -18 are civil, nautical';
say 'and astronomical twilight.';
```

```output
altitude -0.833 -> rise=04:06 set=19:26
altitude -6.000 -> rise=03:31 set=20:01
altitude -12.000 -> rise=02:46 set=20:47
altitude -18.000 -> rise=01:50 set=21:42

-0.833 is the default: the sun's upper limb at the horizon,
allowing for refraction. -6, -12 and -18 are civil, nautical
and astronomical twilight.
```

## When the sun does not rise

```raku name="polar"
use Astro::Sunrise;

# Longyearbyen, Svalbard, at midwinter
my $date = Date.new(2024, 12, 21);
my $r = try sunrise($date, 15.6, 78.22, 1);
say 'polar night : ', $! ?? "threw {$!.^name}: {$!.message.trim}" !! $r.raku;
```

```output
polar night : threw X::AdHoc: Sun never rises!!
```

The module `fail`s deep inside with a message, and because nothing inspects
the `Failure` it detonates a few frames later. It is catchable and the message
survives, but it arrives as an untyped `X::AdHoc` — so nothing distinguishes
"never rises" from "never sets" except the string.

## The one thing to know

**Longitude comes before latitude**, and the swap is silent.

```raku name="order-trap"
use Astro::Sunrise;

my $date = Date.new(2024, 6, 21);

# Rome is latitude 41.90 N, longitude 12.50 E. Both numbers are legal
# latitudes, so nothing can detect the transposition.
my ($a, $b) = sunrise($date, 41.90, 12.50, 2);   # latitude first: wrong
my ($c, $d) = sunrise($date, 12.50, 41.90, 2);   # longitude first: right

say "latitude first (wrong)  : rise=$a set=$b";
say "longitude first (right) : rise=$c set=$d";
say 'no warning, no exception — both look like plausible clock times';
```

```output
latitude first (wrong)  : rise=04:47 set=17:41
longitude first (right) : rise=05:33 set=20:50
no warning, no exception — both look like plausible clock times
```

Forty-six minutes wrong at sunrise and three hours wrong at sunset, with
nothing to tell you. Every routine here takes `$lon` then `$lat`, while nearly
every other geographic interface reads the other way — and the distribution's
own `Astro::Location` class lists `lat` before `lon` in its accessors, which
does not help.

You are only caught out loudly if your longitude happens to exceed 90.

## Where the two engines differ

Nowhere, now. Until recently `:iter` — the refinement pass that converges on a
more accurate time — returned midnight for every location under Raku++,
because the module's convergence test builds its format string as
`sprintf("%.{$dp}g", $A)` and the engine mis-parsed `%.` followed by a block
as an attribute subscript. The format came back as just `"g"`, so the test
compared `"g"` with `"g"`, declared success on the first pass, and the
refinement never ran.

That is fixed, and `:iter` now agrees:

```raku name="iter"
use Astro::Sunrise;

my $date = Date.new(2024, 6, 21);
my ($p, $q) = sunrise($date, -71.0589, 42.3601, -5);
my ($r, $s) = sunrise($date, -71.0589, 42.3601, -5, -0.833, :iter);
say "plain    : rise=$p set=$q";
say "iterated : rise=$r set=$s";
```

```output
plain    : rise=04:06 set=19:26
iterated : rise=04:07 set=19:25
```

Two things that are not engine differences and will cost you. **The default
unit is radians** for `Geo::Ellipsoid`'s sibling routines but the default
`$altit` here is degrees; and `sun_rise`/`sun_set`, the two-argument
convenience forms, read `DateTime.now` internally and accept only an integer
day offset — so they cannot answer about an arbitrary date at all.

The bundled `Astro::Location` class is dead weight: no routine in
`Astro::Sunrise` accepts one, `use Astro::Sunrise` does not bring it into
scope, and its `altit` accessor holds an integer **hour** offset rather than
an altitude in degrees, which is a plausible-looking thing to pass into the
wrong parameter.
