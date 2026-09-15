---
name: DateTime::Math
version: 0.6.2
auth: zef:raku-community-modules
kind: Distribution · time
summary: Conversions between a number and a duration unit, plus operators that
  add or subtract a plain number of seconds from a DateTime.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Datetime::Math
source: git://github.com/raku-community-modules/Datetime-Math.git
---

## What it is for

Core Raku lets you add a `Duration` to a `DateTime` and nothing else. So
`$dt + 60` — the most obvious thing anyone writes — is a type error, and you
have to construct a `Duration` to add a minute.

This distribution adds the operators, and a set of unit conversions to go with
them.

## Converting units

```raku name="units"
use DateTime::Math;

for <s m h d w M y> -> $u {
    say sprintf('1 %-2s = %12s seconds', $u, to-seconds(1, $u));
}
say '';
say 'from-seconds(86400, "h")      : ', from-seconds(86400, 'h');
say 'duration-from-to(1, "y", "d") : ', duration-from-to(1, 'y', 'd');
say 'duration-from-to(1, "d", "w") : ', duration-from-to(1, 'd', 'w');
```

```output
1 s  =            1 seconds
1 m  =           60 seconds
1 h  =         3600 seconds
1 d  =        86400 seconds
1 w  =       604800 seconds
1 M  =      2592000 seconds
1 y  =     31536000 seconds

from-seconds(86400, "h")      : 24
duration-from-to(1, "y", "d") : 365
duration-from-to(1, "d", "w") : 0.142857
```

Note `m` is minutes and `M` is months. A single wrong-case character is a
43,200-fold error, and the `DurationUnits` subset accepts both so nothing
warns.

## The operators

```raku name="operators"
use DateTime::Math;

my $dt = DateTime.new(2025, 12, 31, 23, 59, 30, :timezone(0));
say "base      : $dt";
say '+ 30 s    : ', $dt + 30;
say '+ 60 s    : ', $dt + 60;
say '60 + $dt  : ', 60 + $dt;
say '- 90 s    : ', $dt - 90;
say '+ one day : ', $dt + to-seconds(1, 'd');
```

```output
base      : 2025-12-31T23:59:30Z
+ 30 s    : 2026-01-01T00:00:00Z
+ 60 s    : 2026-01-01T00:00:30Z
60 + $dt  : 2026-01-01T00:00:30Z
- 90 s    : 2025-12-31T23:58:00Z
+ one day : 2026-01-01T23:59:30Z
```

The year-end boundary is crossed correctly, and the timezone survives.

Importing `infix:<->` does **not** shadow the core `DateTime - DateTime`,
which still returns a `Duration`:

```raku name="core-minus"
use DateTime::Math;

my $a = DateTime.new(2024, 2, 28, 12, 0, 0, :timezone(0));
my $b = DateTime.new(2024, 3,  1, 12, 0, 0, :timezone(0));
my $d = $b - $a;
say 'DateTime - DateTime still works : ', $d, ' (a ', $d.^name, ')';
```

```output
DateTime - DateTime still works : 172800 (a Duration)
```

## The one thing to know

A month is exactly 30 days and a year exactly 365, so the module's own units
are not self-consistent and its year arithmetic disagrees with core Raku's.

```raku name="calendar-trap"
use DateTime::Math;

say 'the units against each other:';
say '  1 year in months  : ', duration-from-to(1, 'y', 'M'), '   (not 12)';
say '  12 months in days : ', duration-from-to(12, 'M', 'd'), '   (not 365)';
say '';
my $a = DateTime.new(2024, 2, 28, 12, 0, 0, :timezone(0));   # a leap year
say "starting from $a:";
say '  + to-seconds(1, "y") : ', $a + to-seconds(1, 'y');
say '  core .later(:1year)  : ', $a.later(:1year);
say '';
say '  + to-seconds(1, "M") : ', $a + to-seconds(1, 'M');
say '  core .later(:1month) : ', $a.later(:1month);
```

```output
the units against each other:
  1 year in months  : 12.166667   (not 12)
  12 months in days : 360   (not 365)

starting from 2024-02-28T12:00:00Z:
  + to-seconds(1, "y") : 2025-02-27T12:00:00Z
  core .later(:1year)  : 2025-02-28T12:00:00Z

  + to-seconds(1, "M") : 2024-03-29T12:00:00Z
  core .later(:1month) : 2024-03-28T12:00:00Z
```

These are fixed-length spans, not calendar steps. Adding "one year" moves you
to the wrong calendar date whenever a 29 February falls in the interval, and
adding "one month" from 28 February lands on 29 March rather than 28 March.

For calendar arithmetic use core `.later` and `.earlier`. Use this for genuine
durations — a timeout, a retention window, an interval.

## Where the two engines differ

Only in the wording of a rejected unit: Raku++ says `Type check failed…` where
Rakudo says `Constraint type check failed…`. Every value and every rejection
is otherwise identical.

Two naming things worth knowing. The **distribution** is spelled
`Datetime::Math` with a lowercase `t` while the **unit** is `DateTime::Math`
with a capital one, so anything addressing the distribution by name — an
install, an inspection, a metadata lookup — needs the lowercase spelling.

And `DurationUnits` is declared `my`, so you cannot reference the type in your
own signatures; the only thing you can pass is a bare one-character string.
