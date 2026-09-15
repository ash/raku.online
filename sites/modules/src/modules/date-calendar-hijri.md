---
name: Date::Calendar::Hijri
version: 0.1.0
auth: zef:jforget
kind: Distribution · calendars
summary: Convert between Gregorian dates and the arithmetic Hijri calendar —
  a computed thirty-year cycle with no moon sighting — with day names and
  strftime.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Date::Calendar::Strftime
raku-land: https://raku.land/zef:jforget/Date::Calendar::Hijri
source: https://github.com/jforget/raku-Date-Calendar-Hijri.git
---

## What it is for

The Islamic calendar is lunar, so its months drift about eleven days a year
against the Gregorian one, and a date in one says nothing obvious about the
other. Anything that has to display both — a diary, an archive of dated
documents, a scheduling system used across the Muslim world — needs the
conversion.

This distribution implements the *arithmetic* variant: a purely computed
thirty-year cycle of alternating thirty- and twenty-nine-day months, with no
observational input.

## Converting a date

```raku name="hijri"
use Date::Calendar::Hijri;

my $g = Date.new('2026-09-14');
my $h = Date::Calendar::Hijri.new-from-date($g);

say "gregorian in : $g";
say 'gist         : ', $h.gist;
say 'year/mon/day : ', $h.year, ' / ', $h.month, ' / ', $h.day;
say 'month-name   : ', $h.month-name, '   abbr ', $h.month-abbr;
say 'day-name     : ', $h.day-name, '   abbr ', $h.day-abbr;
say 'day-of-week  : ', $h.day-of-week, '   day-of-year ', $h.day-of-year;
say 'week-number  : ', $h.week-number, '   week-year ', $h.week-year;
say 'daycount     : ', $h.daycount;
say 'strftime     : ', $h.strftime('%Y-%m-%d %A %B');
say '';
say 'round trip   : ', $h.to-date, '   exact : ', $h.to-date == $g;
```

```output
gregorian in : 2026-09-14
gist         : 1448-04-01
year/mon/day : 1448 / 4 / 1
month-name   : Rabi` al-Thaani   abbr R.T
day-name     : Yaum al-Ithnain   abbr Ith
day-of-week  : 2   day-of-year 90
week-number  : 14   week-year 1448
daycount     : 61297
strftime     : 1448-04-01 Yaum al-Ithnain Rabi` al-Thaani

round trip   : 2026-09-14   exact : True
```

The round trip is exact. `daycount` is the Modified Julian Day, which is the
common currency between every calendar in this family.

## The epoch

```raku name="epoch"
use Date::Calendar::Hijri;

for '0622-07-19', '0700-01-01', '1900-01-01' -> $d {
    my $h = Date::Calendar::Hijri.new-from-date(Date.new($d));
    say sprintf('%s -> %s   back=%s exact=%s',
        $d, $h.gist, $h.to-date, $h.to-date == Date.new($d));
}
say '';
say 'earlier than that is refused:';
my $r = try Date::Calendar::Hijri.new-from-date(Date.new('0622-07-18'));
say '  0622-07-18 : ', $! ?? 'refused' !! 'accepted';
```

```output
0622-07-19 -> 0001-01-01   back=0622-07-19 exact=True
0700-01-01 -> 0080-11-01   back=0700-01-01 exact=True
1900-01-01 -> 1317-08-28   back=1900-01-01 exact=True

earlier than that is refused:
  0622-07-18 : refused
```

The epoch is 19 July 622, which is Hijri 0001-01-01. Anything earlier is
outside the calendar.

## Day-of-week numbering

```raku name="dow"
use Date::Calendar::Hijri;

my $g = Date.new('2026-09-14');     # a Monday
say "gregorian $g is a Monday";
say '  Raku Date.day-of-week  : ', $g.day-of-week;
say '  Hijri  .day-of-week    : ', Date::Calendar::Hijri.new-from-date($g).day-of-week;
say '  Hijri  .day-name       : ', Date::Calendar::Hijri.new-from-date($g).day-name;
say '';
say 'the Hijri week starts on Sunday and Raku counts from Monday,';
say 'so the same day has two different numbers.';
```

```output
gregorian 2026-09-14 is a Monday
  Raku Date.day-of-week  : 1
  Hijri  .day-of-week    : 2
  Hijri  .day-name       : Yaum al-Ithnain

the Hijri week starts on Sunday and Raku counts from Monday,
so the same day has two different numbers.
```

## The one thing to know

One Hijri date maps to **two** Gregorian days, and `to-date` is not the
inverse of `new-from-date`.

```raku name="daypart-trap"
use Date::Calendar::Hijri;
use Date::Calendar::Strftime;

my $day = Date::Calendar::Hijri.new(year => 1448, month => 4, day => 2);
my $eve = Date::Calendar::Hijri.new(year => 1448, month => 4, day => 2,
                                    daypart => after-sunset());

say 'Hijri 1448-04-02 in daylight     -> ', $day.to-date;
say 'Hijri 1448-04-02 after sunset    -> ', $eve.to-date;
say 'the same Hijri date, a day apart : ', $day.to-date - $eve.to-date;
say '';
my $g = Date.new('2026-09-14');
say "Gregorian $g in daylight  -> ",
    Date::Calendar::Hijri.new-from-daycount($g.daycount, daypart => daylight()).gist;
say "Gregorian $g after sunset -> ",
    Date::Calendar::Hijri.new-from-daycount($g.daycount, daypart => after-sunset()).gist;
```

```output
Hijri 1448-04-02 in daylight     -> 2026-09-15
Hijri 1448-04-02 after sunset    -> 2026-09-14
the same Hijri date, a day apart : 1

Gregorian 2026-09-14 in daylight  -> 1448-04-01
Gregorian 2026-09-14 after sunset -> 1448-04-02
```

The Hijri day begins at sunset, and the module models that. The conversion is
a mapping between **day-parts**, not between days. Convert a Gregorian date in
and straight back out and you are fine — but hand the module a Hijri date that
came from an evening event and `to-date` lands a day earlier than the same
numerals would give you in daylight.

`Date::Calendar::Bahai` behaves the same way; `Date::Calendar::Persian` does
not, because its daypart is inert. Code written against one and reused on
another behaves differently for the same argument, with no error.

## Where the two engines differ

On the exception a bad month or day produces, which matters if you are
catching it.

Every class in this family validates twice: a `where` constraint on the
attribute and an explicit range check in `BUILD` that throws a well-described
`X::OutOfRange`. Rakudo runs `BUILD` and you get `Month out of range. Is: 13,
should be in 1..12`. Raku++ fills the attributes from the named arguments
before `BUILD` runs, so the `where` constraint fires first and you get
`X::TypeCheck::Assignment` with no range in the message.

Both refuse the date. Only one tells you what the range was.

Two other things, neither engine-related. This is the **arithmetic** Hijri
only — there is no astronomical or observational variant here, so it will not
in general match locally announced dates. And alone among the four calendars
in this family it has **no `locale` method**, so you get the one set of names.
