---
name: Date::Christian::Advent
version: 0.0.2
auth: zef:tbrowder
kind: Distribution · calendars
summary: The date of the First Sunday of Advent for a year, computed three
  independent ways — which all agree.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:tbrowder/Date::Christian::Advent
source: https://github.com/tbrowder/Date-Christian-Advent.git
---

## What it is for

Advent Sunday starts the Western liturgical year, and it moves: it is the
Sunday nearest 30 November, which can be anywhere from 27 November to 3
December. Anything that lays out a church calendar, or that schedules against
one, needs the computation.

This distribution is that computation, offered three times over with three
different derivations.

## Finding Advent Sunday

```raku name="advent"
use Date::Christian::Advent;

my %published =
    2000 => '2000-12-03', 2012 => '2012-12-02', 2016 => '2016-11-27',
    2020 => '2020-11-29', 2021 => '2021-11-28', 2022 => '2022-11-27',
    2023 => '2023-12-03', 2024 => '2024-12-01', 2025 => '2025-11-30',
    2026 => '2026-11-29';

for %published.keys.sort({ +$_ }) -> $y {
    my $a = Advent-Sunday(+$y);
    say sprintf('%s  %s  published=%s  %s   (30 Nov is a %s)',
        $y, $a.Str, %published{$y},
        $a.Str eq %published{$y} ?? 'match' !! 'DIFFERS',
        <Mon Tue Wed Thu Fri Sat Sun>[Date.new(+$y, 11, 30).day-of-week - 1]);
}
```

```output
2000  2000-12-03  published=2000-12-03  match   (30 Nov is a Thu)
2012  2012-12-02  published=2012-12-02  match   (30 Nov is a Fri)
2016  2016-11-27  published=2016-11-27  match   (30 Nov is a Wed)
2020  2020-11-29  published=2020-11-29  match   (30 Nov is a Mon)
2021  2021-11-28  published=2021-11-28  match   (30 Nov is a Tue)
2022  2022-11-27  published=2022-11-27  match   (30 Nov is a Wed)
2023  2023-12-03  published=2023-12-03  match   (30 Nov is a Thu)
2024  2024-12-01  published=2024-12-01  match   (30 Nov is a Sat)
2025  2025-11-30  published=2025-11-30  match   (30 Nov is a Sun)
2026  2026-11-29  published=2026-11-29  match   (30 Nov is a Mon)
```

Every answer matches the published date, across four leap years and every
weekday position of 30 November.

## The three routines

```raku name="three"
use Date::Christian::Advent;

my @bad;
for 1583 .. 2500 -> $y {
    my ($a, $b, $c) = Advent-Sunday($y), Advent-Sunday2($y), Advent-Sunday3($y);
    @bad.push("$y: $a / $b / $c") unless $a == $b == $c;
}
say 'years scanned : ', 2500 - 1583 + 1;
say 'disagreements : ', @bad.elems;
say '';
say 'one year per weekday position of 30 November:';
my %done;
for 2000 .. 2050 -> $y {
    my $d = Date.new($y, 11, 30).day-of-week;
    next if %done{$d}++;
    say sprintf('  30 Nov is weekday %d  (%d) : %s  %s  %s',
        $d, $y, Advent-Sunday($y), Advent-Sunday2($y), Advent-Sunday3($y));
}
```

```output
years scanned : 918
disagreements : 0

one year per weekday position of 30 November:
  30 Nov is weekday 4  (2000) : 2000-12-03  2000-12-03  2000-12-03
  30 Nov is weekday 5  (2001) : 2001-12-02  2001-12-02  2001-12-02
  30 Nov is weekday 6  (2002) : 2002-12-01  2002-12-01  2002-12-01
  30 Nov is weekday 7  (2003) : 2003-11-30  2003-11-30  2003-11-30
  30 Nov is weekday 2  (2004) : 2004-11-28  2004-11-28  2004-11-28
  30 Nov is weekday 3  (2005) : 2005-11-27  2005-11-27  2005-11-27
  30 Nov is weekday 1  (2009) : 2009-11-29  2009-11-29  2009-11-29
```

## The one thing to know

The three exported routines are not three algorithms with three answers. They
are provably one function under three names.

The export list invites the opposite reading: Advent *does* have competing
definitions in other traditions, and a distribution offering
`Advent-Sunday`, `Advent-Sunday2` and `Advent-Sunday3` looks like it is
offering you a choice. It is not. One finds the Sunday nearest 30 November,
one takes the Sunday after November's last Thursday, one counts back four
Sundays from Christmas — and for the Western calendar those are the same day,
every time, which the 918-year sweep above demonstrates.

Pick `Advent-Sunday` and ignore the other two.

## Where the two engines differ

Only outside the Christian era, where nothing here is meaningful anyway.

`Date.day-of-week` disagrees between the engines for BC years, and the
formatting of a negative year differs too — Raku++ prints `-001-11-27` where
Rakudo prints `-0001-11-28`. So `Advent-Sunday(-1)` gives different answers on
the two engines, from identical daycounts. Each engine is internally
consistent; the sequences are offset.

Rakudo also warns `Use of Nil in numeric context` where Raku++ is silent,
which brings up the thing worth guarding against on both. The year parameter
is **untyped**, so there is no validation whatsoever:

```raku name="untyped"
use Date::Christian::Advent;

for '2025', 2025.0, 2025.5, 0 -> $y {
    my $r = try Advent-Sunday($y);
    say sprintf('Advent-Sunday(%-8s) -> %s', $y.raku, $r.defined ?? $r.Str !! 'threw');
}
```

```output
Advent-Sunday("2025"  ) -> 2025-11-30
Advent-Sunday(2025.0  ) -> 2025-11-30
Advent-Sunday(2025.5  ) -> 2025-11-30
Advent-Sunday(0       ) -> 0000-12-03
```

`2025.5` silently truncates to 2025, and the only guard anywhere is whatever
`Date.new` happens to reject. Coerce with `.Int` at your own call site.
