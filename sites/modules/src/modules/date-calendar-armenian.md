---
name: Date::Calendar::Armenian
version: 0.1.0
auth: zef:jforget
kind: Distribution · calendars
summary: The Armenian civil calendar — twelve thirty-day months plus five
  aveliats, 365 days flat, no leap day ever.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Date::Calendar::Strftime
raku-land: https://raku.land/zef:jforget/Date::Calendar::Armenian
source: https://github.com/jforget/raku-Date-Calendar-Armenian.git
---

## What it is for

The Armenian era counts from 11 July 552 in the Julian calendar. Its year has
twelve months of exactly thirty days, followed by a thirteenth month of five
*aveliats* — 365 days, and no intercalation of any kind.

This distribution converts between core `Date` and that calendar, carries the
Armenian month and day names, and composes `Date::Calendar::Strftime` so you
can format a date the way `strftime` does.

## Converting

```raku name="convert"
use Date::Calendar::Armenian;

my $g = Date.new(2025, 4, 3);
my $a = Date::Calendar::Armenian.new-from-date($g);

say 'gregorian   : ', $g;
say 'armenian    : ', $a.gist;
say '  month     : ', $a.month, '  ', $a.month-name, ' (', $a.month-abbr, ')';
say '  day-name  : ', $a.day-name;
say '  month-day : ', $a.month-day-name;
say '  doy       : ', $a.day-of-year;
say '  daycount  : ', $a.daycount, '   (Date.daycount = ', $g.daycount, ')';
say '  strftime  : ', $a.strftime('%Y-%m-%d %A %B %Oj');
say '';
say 'back to Date: ', $a.to-date, '  same? ', $a.to-date == $g;
```

```output
gregorian   : 2025-04-03
armenian    : 1474-09-17
  month     : 9  ahekan-i (Ahe)
  day-name  : hingšabatʿi
  month-day : asak
  doy       : 257
  daycount  : 60768   (Date.daycount = 60768)
  strftime  : 1474-09-17 hingšabatʿi ahekan-i 257

back to Date: 2025-04-03  same? True
```

`.daycount` is the Modified Julian Day, so it is directly comparable with
core `Date.daycount`.

## The shape of the year

```raku name="year"
use Date::Calendar::Armenian;

say 'the epoch, 1 Nawasard 1:';
my $epoch = Date::Calendar::Armenian.new(year => 1, month => 1, day => 1);
say '  MJD ', $epoch.daycount, ' = ', $epoch.to-date;
say '';
say 'the thirteenth month holds exactly five days:';
for 5, 6 -> $d {
    my $r = try Date::Calendar::Armenian.new(year => 1474, month => 13, day => $d);
    say sprintf('  month 13 day %d -> %s', $d, $! ?? 'refused' !! $r.gist);
}
say '';
say 'and there is no year 0 — the day before the epoch cannot be built:';
my $r = try Date::Calendar::Armenian.new-from-date($epoch.to-date - 1);
say '  ', $! ?? 'refused' !! $r.gist;
```

```output
the epoch, 1 Nawasard 1:
  MJD -477133 = 0552-07-13

the thirteenth month holds exactly five days:
  month 13 day 5 -> 1474-13-05
  month 13 day 6 -> refused

and there is no year 0 — the day before the epoch cannot be built:
  refused
```

## The one thing to know

The Armenian year is 365 days, always. A fixed Armenian date is therefore
**not** a fixed Gregorian date — it slides one day earlier every four years.

```raku name="slide"
use Date::Calendar::Armenian;

for 1474 .. 1482 -> $y {
    my $a = Date::Calendar::Armenian.new(year => $y, month => 9, day => 17);
    say sprintf('  arm %d-09-17  ->  %s', $y, $a.to-date);
}
say '';
say 'a birthday or anniversary computed once and cached is wrong';
say 'within four years. Recompute it, or store the Gregorian date.';
```

```output
  arm 1474-09-17  ->  2025-04-03
  arm 1475-09-17  ->  2026-04-03
  arm 1476-09-17  ->  2027-04-03
  arm 1477-09-17  ->  2028-04-02
  arm 1478-09-17  ->  2029-04-02
  arm 1479-09-17  ->  2030-04-02
  arm 1480-09-17  ->  2031-04-02
  arm 1481-09-17  ->  2032-04-01
  arm 1482-09-17  ->  2033-04-01

a birthday or anniversary computed once and cached is wrong
within four years. Recompute it, or store the Gregorian date.
```

## Where the two engines differ

Nothing in the arithmetic. Two things about the *edges* of the API are worth
knowing before you write portable code, and both are identical on the two
engines — only the exception text differs (Raku++ says `Type check failed on
attribute '$!year'; the value does not satisfy its where constraint` where
Rakudo says `Type check failed in assignment to $!year; expected <anon> but
got Int (0)`). Do not match on the message.

The week numbering is the substantive trap:

```raku name="dow"
use Date::Calendar::Armenian;

my $g = Date.new(2025, 4, 6);   # a Sunday
my $a = Date::Calendar::Armenian.new-from-date($g);
say 'gregorian 2025-04-06 is a Sunday';
say '  Date.day-of-week      = ', $g.day-of-week, '   (Monday = 1)';
say '  Armenian day-of-week  = ', $a.day-of-week, '   (kiraki = 1)';
say '';
say 'the two are a rotation apart. Indexing a weekday table with the';
say 'wrong one is silently off by six.';
```

```output
gregorian 2025-04-06 is a Sunday
  Date.day-of-week      = 7   (Monday = 1)
  Armenian day-of-week  = 1   (kiraki = 1)

the two are a rotation apart. Indexing a weekday table with the
wrong one is silently off by six.
```

The three-valued `daypart` is the other one. `before-sunrise()` shifts
`.daycount` by a day while leaving `gist` alone, so two objects with the same
`gist` can answer different Gregorian dates — and `to-date` drops the daypart
entirely, because core `Date` has no such thing and a Raku method's implicit
`*%_` swallows the named argument without a word.
