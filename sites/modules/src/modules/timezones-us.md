---
name: Timezones::US
version: 0.0.7
auth: zef:tbrowder
kind: Distribution · time
summary: The nine US standard-time zones and the post-2007 DST transition
  rule — computed from the calendar, not from a database.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:tbrowder/Timezones::US
source: https://github.com/tbrowder/Timezones-US.git
---

## What it is for

United States daylight saving has followed one rule since 2007: it begins on
the second Sunday in March and ends on the first Sunday in November, both at
02:00 local. That rule is small enough to compute, which is what this
distribution does — no tzdata, no system calls, nine hard-coded zone
abbreviations and a handful of `Date` arithmetic.

## The transition instants

```raku name="transitions"
use Timezones::US;

for 2007, 2020, 2024, 2025, 2026 -> $y {
    say sprintf('%d  begin %s   end %s', $y, begin-dst($y), end-dst($y));
}
say '';
say 'those match the published second-Sunday-in-March /';
say 'first-Sunday-in-November rule, including the years where';
say '1 November is itself a Sunday (2020, 2026).';
```

```output
2007  begin 2007-03-11T02:00:00Z   end 2007-11-04T02:00:00Z
2020  begin 2020-03-08T02:00:00Z   end 2020-11-01T02:00:00Z
2024  begin 2024-03-10T02:00:00Z   end 2024-11-03T02:00:00Z
2025  begin 2025-03-09T02:00:00Z   end 2025-11-02T02:00:00Z
2026  begin 2026-03-08T02:00:00Z   end 2026-11-01T02:00:00Z

those match the published second-Sunday-in-March /
first-Sunday-in-November rule, including the years where
1 November is itself a Sunday (2020, 2026).
```

Both are stamped `Z` because they are built with no timezone. They *mean*
02:00 local; compare them only with other naive `DateTime`s.

## Asking whether a moment is in DST

```raku name="is-dst"
use Timezones::US;

for DateTime.new(2025, 7, 4, 12, 0, 0),
    DateTime.new(2025, 1, 4, 12, 0, 0),
    DateTime.new(2025, 3, 9,  2, 0, 0),
    DateTime.new(2025, 11, 2, 2, 0, 0) -> $t {
    say sprintf('%s -> %s', $t, is-dst(localtime => $t));
}
say '';
say 'the boundary is CLOSED at both ends: the November instant is the';
say 'moment DST has just ended, and it still answers True.';
```

```output
2025-07-04T12:00:00Z -> True
2025-01-04T12:00:00Z -> False
2025-03-09T02:00:00Z -> True
2025-11-02T02:00:00Z -> True

the boundary is CLOSED at both ends: the November instant is the
moment DST has just ended, and it still answers True.
```

## The zone tables

```raku name="zones"
use Timezones::US;

say 'zones : ', @tz.elems;
for @tz -> $z {
    say sprintf('  %-6s %+3d  %s', $z, %utc-offsets{$z}, %tzones{$z}<name>);
}
say '';
say 'DST exceptions the module knows about: ', %dst-exceptions.keys.sort.join(', ');
```

```output
zones : 9
  ast     -4  Atlantic
  est     -5  Eastern
  cst     -6  Central
  mst     -7  Mountain
  pst     -8  Pacific
  akst    -9  Alaska
  hast   -10  Hawaii-Aleutian
  wst    -11  Samoa
  chst   +10  Chamorro

DST exceptions the module knows about: mst
```

Note that `is-dst` never looks at a zone. Ask about Guam — `chst`, UTC+10, no
DST — in July and you get `True`, because the zone tables and the DST answer
are two unconnected halves of the same distribution.

## The one thing to know

The `:year`-style `is-dst` accepts `:minute` and throws it away. Near a
transition it therefore returns the wrong answer, silently.

```raku name="minute"
use Timezones::US;

my $t = DateTime.new(2025, 11, 2, 2, 1, 0);
say 'instant                      : ', $t;
say '  is-dst(localtime => $t)     : ', is-dst(localtime => $t);
say '  is-dst(:year …, :minute(1)) : ',
    is-dst(year => 2025, month => 11, day => 2, hour => 2, minute => 1);
say '';
say ':second IS forwarded, which is what makes this hard to spot —';
my $s = DateTime.new(2025, 11, 2, 2, 0, 1);
say '  is-dst(localtime => $s)     : ', is-dst(localtime => $s);
say '  is-dst(:year …, :second(1)) : ',
    is-dst(year => 2025, month => 11, day => 2, hour => 2, second => 1);
```

```output
instant                      : 2025-11-02T02:01:00Z
  is-dst(localtime => $t)     : False
  is-dst(:year …, :minute(1)) : True

:second IS forwarded, which is what makes this hard to spot —
  is-dst(localtime => $s)     : False
  is-dst(:year …, :second(1)) : False
```

The body builds `DateTime.new(:$year, :$month, :$day, :$hour, :$second)`.
`$minute` is declared, defaulted, shown in the signature, and never used.

## Where the two engines differ

The exported `@tz`, `%tzones`, `%utc-offsets` and `%offsets-utc` are declared
`constant`. Under Rakudo that binds an immutable `List` and `Map`; under
Raku++ it binds a mutable `Array` and `Hash`, so any consumer can rewrite the
module's tables for the rest of the process.

```raku name="mutability"
use Timezones::US;

# read them, copy them, and never write through the exported name
my %mine = %tzones.keys.map({ $_ => %tzones{$_}<name> });
say 'a copy is yours to change:';
%mine<cst> = 'Central (mine)';
say '  %mine<cst>   : ', %mine<cst>;
say '  %tzones<cst> : ', %tzones<cst><name>, '   — untouched';
say '';
say 'Rakudo refuses a write through %tzones with X::Assignment::RO;';
say 'Raku++ accepts it and the change is visible to every other consumer';
say 'for the rest of the process. Copy first.';
```

```output
a copy is yours to change:
  %mine<cst>   : Central (mine)
  %tzones<cst> : Central   — untouched

Rakudo refuses a write through %tzones with X::Assignment::RO;
Raku++ accepts it and the change is visible to every other consumer
for the rest of the process. Copy first.
```

Two smaller notes, both identical on the two engines. `show-us-data` is
declared `--> Str` and in fact returns `Any` while printing to stdout — do not
capture it. And `is-dst()` with no arguments dies: the second multi's
`:$localtime` is optional, so you get a `DateTime` type object and a
method-not-found a frame down.
