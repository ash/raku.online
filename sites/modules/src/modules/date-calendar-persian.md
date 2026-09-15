---
name: Date::Calendar::Persian
version: 0.1.0
auth: zef:jforget
kind: Distribution · calendars
summary: Convert between Gregorian dates and the Persian solar calendar,
  whose year begins at the spring equinox, in an arithmetic and an
  astronomical reckoning.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Date::Calendar::Strftime
raku-land: https://raku.land/zef:jforget/Date::Calendar::Persian
source: https://github.com/jforget/raku-Date-Calendar-Persian.git
---

## What it is for

The Persian, or Jalali, calendar is the civil calendar of Iran and
Afghanistan, and it is the most astronomically accurate solar calendar in use:
its year begins at the instant of the spring equinox, so it needs no leap
rule at all if you are willing to compute the equinox.

Converting to and from it is what anything displaying both calendars needs.

## Converting a date

```raku name="persian"
use Date::Calendar::Persian;

my $g = Date.new('2026-09-14');
my $p = Date::Calendar::Persian.new-from-date($g);

say "gregorian in : $g";
say 'gist         : ', $p.gist;
say 'year/mon/day : ', $p.year, ' / ', $p.month, ' / ', $p.day;
say 'month-name   : ', $p.month-name, '   abbr ', $p.month-abbr;
say 'day-name     : ', $p.day-name, '   abbr ', $p.day-abbr;
say 'day-of-week  : ', $p.day-of-week, '   day-of-year ', $p.day-of-year;
say 'week-number  : ', $p.week-number, '   week-year ', $p.week-year;
say 'daycount     : ', $p.daycount;
say 'strftime     : ', $p.strftime('%Y-%m-%d %A %B');
say '';
say 'round trip   : ', $p.to-date, '   exact : ', $p.to-date == $g;
```

```output
gregorian in : 2026-09-14
gist         : 1405-06-23
year/mon/day : 1405 / 6 / 23
month-name   : Shahrivar   abbr Sha
day-name     : Do shanbe   abbr 2sh
day-of-week  : 3   day-of-year 178
week-number  : 26   week-year 1405
daycount     : 61297
strftime     : 1405-06-23 Do shanbe Shahrivar

round trip   : 2026-09-14   exact : True
```

## Nowruz

```raku name="nowruz"
use Date::Calendar::Persian;

say 'the first day of each Persian year, in Gregorian terms:';
for 1403, 1404, 1405, 1406 -> $y {
    my $p = Date::Calendar::Persian.new(year => $y, month => 1, day => 1);
    say sprintf('  Persian %d-01-01 = %s', $y, $p.to-date);
}
```

```output
the first day of each Persian year, in Gregorian terms:
  Persian 1403-01-01 = 2024-03-20
  Persian 1404-01-01 = 2025-03-20
  Persian 1405-01-01 = 2026-03-21
  Persian 1406-01-01 = 2027-03-21
```

Nowruz lands on 20 or 21 March, which is the equinox rather than a fixed date.

## The epoch

```raku name="epoch"
use Date::Calendar::Persian;

for '0622-03-22', '1000-01-01', '2000-01-01' -> $d {
    my $p = Date::Calendar::Persian.new-from-date(Date.new($d));
    say sprintf('%s -> %s   back=%s exact=%s',
        $d, $p.gist, $p.to-date, $p.to-date == Date.new($d));
}
say '';
my $r = try Date::Calendar::Persian.new-from-date(Date.new('0500-01-01'));
say 'before the epoch : ', $! ?? 'refused' !! 'accepted';
```

```output
0622-03-22 -> 0001-01-01   back=0622-03-22 exact=True
1000-01-01 -> 0378-10-11   back=1000-01-01 exact=True
2000-01-01 -> 1378-10-11   back=2000-01-01 exact=True

before the epoch : refused
```

22 March 622 is Persian 0001-01-01.

## The one thing to know

The arithmetic and astronomical classes disagree by a full day for an entire
Persian year at a time.

```raku name="variants-trap"
use Date::Calendar::Persian;
use Date::Calendar::Persian::Astronomical;

my @disagree = (Date.new('2024-06-01') .. Date.new('2026-09-01')).grep({
    Date::Calendar::Persian.new-from-date($_).gist
      ne Date::Calendar::Persian::Astronomical.new-from-date($_).gist
});

say 'days where the two classes disagree : ', @disagree.elems;
say '  first : ', @disagree[0];
say '  last  : ', @disagree[*-1];
say '  one contiguous run : ', @disagree[*-1] - @disagree[0] + 1 == @disagree.elems;
say '';
my $g = Date.new('2025-06-15');
say "inside that window, $g:";
say '  arithmetic   : ', Date::Calendar::Persian.new-from-date($g).gist;
say '  astronomical : ', Date::Calendar::Persian::Astronomical.new-from-date($g).gist;
```

```output
days where the two classes disagree : 366
  first : 2025-03-20
  last  : 2026-03-20
  one contiguous run : True

inside that window, 2025-06-15:
  arithmetic   : 1404-03-26
  astronomical : 1404-03-25
```

Three hundred and sixty-six consecutive days — the whole of Persian year 1404
— where the two differ by exactly one day, because they place Nowruz 1404 on
different Gregorian days. Outside that run they agree exactly.

A programmer who picks a class arbitrarily gets correct dates for years, then
a year of silently off-by-one dates, then correct dates again. Nothing warns
you, both classes have the same interface, and neither errors.

Decide which reckoning your application means and name the class explicitly
everywhere.

## Where the two engines differ

On the exception a bad month or day produces — the same pattern as the rest of
this family. Rakudo reaches the explicit range check in `BUILD` and reports
`Day out of range. Is: 32, should be in 1..31 for this month and this year`;
Raku++ fills the attribute from the named argument first, so the `where`
constraint fires and the message carries no range.

Both refuse the date.

One thing that is not an engine difference and that distinguishes this
calendar from its siblings: **`daypart` is silently inert here**. All three
values give the same result, where Hijri and Baháʼí both shift by a day at
`after-sunset`. Code written against one of those and reused here behaves
differently for the same argument, with no error. Persian also has no
`is-leap` and no `locale`.
