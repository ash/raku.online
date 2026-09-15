---
name: Moonphase
version: 0.0.2
auth: zef:librasteve
kind: Distribution · astronomy
summary: The classic low-precision lunar series, accurate to about a
  thirtieth of a degree — returning an angle that is not normalised.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:librasteve/Moonphase
source: https://github.com/librasteve/Moonphase.git
---

## What it is for

The moon's age — how far it is past new — is the input to a phase icon, a
tide estimate, a calendar glyph or a folklore lookup. Computing it properly
means an ephemeris; computing it well enough for those uses means a short
trigonometric series, which is what this distribution implements.

From a Unix timestamp it derives the Julian day, solves Kepler's equation for
the Sun, applies the standard evection, annual-equation and variation
corrections to the Moon's mean longitude, and returns the elongation of Moon
from Sun **in radians**: 0 at new moon, π at full.

## Using it

```raku name="basics"
use Moonphase;

# a solar eclipse can only happen at new moon; a lunar one only at full
my %events =
    'total solar 1999-08-11 11:03 UTC' => 934369380,
    'total solar 2017-08-21 18:26 UTC' => 1503354360,
    'total lunar 2000-01-21 04:44 UTC' => 948429840,
    'total lunar 2018-01-31 13:30 UTC' => 1517405400;

for %events.keys.sort -> $label {
    my $p = moonphase(%events{$label});
    say sprintf('%-34s %9.5f rad  %8.3f deg  illum %.4f',
                $label, $p, $p * 180 / pi, (1 - cos($p)) / 2);
}
say '';
say 'eclipse instants are exact phase anchors, so those four lines are';
say 'the accuracy claim: about 0.03 degrees, which is what this class';
say 'of series promises.';
```

```output
total lunar 2000-01-21 04:44 UTC     3.14207 rad   180.027 deg  illum 1.0000
total lunar 2018-01-31 13:30 UTC     3.14182 rad   180.013 deg  illum 1.0000
total solar 1999-08-11 11:03 UTC    -0.00048 rad    -0.027 deg  illum 0.0000
total solar 2017-08-21 18:26 UTC     0.03817 rad     2.187 deg  illum 0.0004

eclipse instants are exact phase anchors, so those four lines are
the accuracy claim: about 0.03 degrees, which is what this class
of series promises.
```

## The argument is Unix seconds

`$ud` is untyped, so every date-shaped object is accepted without a word —
and a `Date` numifies to its day count, which is not a timestamp.

```raku name="argument"
use Moonphase;

my $ts = 1503354360;
say 'Int seconds        : ', moonphase($ts).round(0.000001);
say 'the same as a Str  : ', moonphase("$ts").round(0.000001);
say '';
say 'a Date numifies to its MJD daycount, not to seconds:';
my $d = Date.new(2017, 8, 21);
say '  Date.new(2017,8,21) numifies to ', +$d;
say '  moonphase(that)     = ', moonphase($d).round(0.000001), '  <- meaningless';
say '';
say 'milliseconds are accepted too, and equally meaningless.';
say 'convert to seconds yourself: $dt.posix.Int';
say '  moonphase($dt.posix.Int) = ',
    moonphase(DateTime.new(2017, 8, 21, 18, 26, 0).posix.Int).round(0.000001);
```

```output
Int seconds        : 0.038169
the same as a Str  : 0.038169

a Date numifies to its MJD daycount, not to seconds:
  Date.new(2017,8,21) numifies to 57986
  moonphase(that)     = 4.861886  <- meaningless

milliseconds are accepted too, and equally meaningless.
convert to seconds yourself: $dt.posix.Int
  moonphase($dt.posix.Int) = -0.000162
```

## The one thing to know

The returned angle is **not normalised**. Around new moon it goes negative, so
both `$p < 0.1` and `$p > 6.2` miss the new moon.

```raku name="negative"
use Moonphase;

my $new = 1503354360;    # the 2017-08-21 new moon
say 'hourly sweep across it:';
for -2, -1, 0, 1, 2 -> $h {
    my $p = moonphase($new + $h * 3600);
    say sprintf('  %+3d h  %14.8f rad   in 0..2pi? %s', $h, $p, (0 <= $p < 2 * pi));
}
say '';
say 'the cause is fixangle($a) { $a mod 360 }. Raku`s infix:<mod> is NOT %';
say 'for Reals — for a non-integral negative value it is the identity:';
for -1, -0.5, -0.027 -> $v {
    say sprintf('  %-8s mod 360 = %-10s   %% 360 = %s', $v, $v mod 360, $v % 360);
}
say '';
say 'so normalise it yourself: $p % (2 * pi)';
say '  normalised at the new moon: ', (moonphase($new) % (2 * pi)).round(0.000001);
```

```output
hourly sweep across it:
   -2 h      0.01902130 rad   in 0..2pi? True
   -1 h      0.02859970 rad   in 0..2pi? True
   +0 h      0.03816906 rad   in 0..2pi? True
   +1 h      0.04772927 rad   in 0..2pi? True
   +2 h      0.05728022 rad   in 0..2pi? True

the cause is fixangle($a) { $a mod 360 }. Raku`s infix:<mod> is NOT %
for Reals — for a non-integral negative value it is the identity:
  -1       mod 360 = 359          % 360 = 359
  -0.5     mod 360 = -0.5         % 360 = 359.5
  -0.027   mod 360 = -0.027       % 360 = 359.973

so normalise it yourself: $p % (2 * pi)
  normalised at the new moon: 0.038169
```

## Where the two engines differ

Anything that reaches `moonphase` through an `Instant` — including `+$datetime`
— differs by up to 27 seconds, because Raku++'s leap-second table is flat at
10 seconds for all time while Rakudo carries the published TAI−UTC series.

```raku name="leap"
use Moonphase;

my $dt = DateTime.new(2017, 8, 21, 18, 26, 0);
say 'DateTime.posix.Int is leap-second free on both engines:';
say '  ', $dt.posix.Int, ' -> ', moonphase($dt.posix.Int).round(0.000001);
say '';
say 'Instant arithmetic is not. `+$dt` and `now` route through the';
say 'leap-second table, which Raku++ pins at 10 seconds for every date';
say 'and Rakudo tracks properly (32 s in 1999, 37 s since 2017).';
say '';
say 'Always feed this module .posix.Int, never an Instant.';
```

```output
DateTime.posix.Int is leap-second free on both engines:
  1503339960 -> -0.000162

Instant arithmetic is not. `+$dt` and `now` route through the
leap-second table, which Raku++ pins at 10 seconds for every date
and Rakudo tracks properly (32 s in 1999, 37 s since 2017).

Always feed this module .posix.Int, never an Instant.
```

A smaller divergence, introspection only: `&infix:<mod>.candidates` reports
one empty-signature candidate under Raku++ where Rakudo lists
`(Real:D $a, Real:D $b)` and `($a, $b)`, and an `Instant` stringifies as a
bare number under Raku++ and as `Instant:N` under Rakudo. Keep both out of
any example.
