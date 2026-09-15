---
name: Date::Calendar::Bahai
version: 0.1.0
auth: zef:jforget
kind: Distribution · calendars
summary: Convert between Gregorian dates and the Baháʼí calendar in both an
  arithmetic and an astronomical reckoning, with the cyclical structure
  exposed alongside year, month and day.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Date::Calendar::Strftime
raku-land: https://raku.land/zef:jforget/Date::Calendar::Bahai
source: https://github.com/jforget/raku-Date-Calendar-Bahai.git
---

## What it is for

The Baháʼí calendar has a structure no other calendar shares: nineteen months
of nineteen days, an intercalary period to make up the difference, and years
grouped into nineteen-year *váhid* cycles inside 361-year *kull-i-shay* major
cycles. A date is not just a year, month and day; it has a position in those
cycles and a name drawn from them.

This distribution converts to and from it, and exposes the cycle structure as
well as the plain fields.

## Converting a date

```raku name="bahai"
use Date::Calendar::Bahai;

my $g = Date.new('2026-09-14');
my $b = Date::Calendar::Bahai.new-from-date($g);

say "gregorian in  : $g";
say 'gist          : ', $b.gist;
say 'year/mon/day  : ', $b.year, ' / ', $b.month, ' / ', $b.day;
say 'month-name    : ', $b.month-name, '   abbr ', $b.month-abbr;
say 'day-name      : ', $b.day-name, '   abbr ', $b.day-abbr;
say 'day-of-week   : ', $b.day-of-week, '   day-of-year ', $b.day-of-year;
say 'major-cycle   : ', $b.major-cycle, '   cycle ', $b.cycle, '   cycle-year ', $b.cycle-year;
say 'cycle-year-nm : ', $b.cycle-year-name;
say 'is-leap       : ', $b.is-leap;
say 'locale        : ', $b.locale;
say 'strftime      : ', $b.strftime('%Y-%m-%d %A %B');
say '';
say 'round trip    : ', $b.to-date, '   exact : ', $b.to-date == $g;
```

```output
gregorian in  : 2026-09-14
gist          : 0183-10-07
year/mon/day  : 183 / 10 / 7
month-name    : 'Izzat   abbr Izz
day-name      : Kamál   abbr Kam
day-of-week   : 3   day-of-year 178
major-cycle   : 1   cycle 10   cycle-year 12
cycle-year-nm : Javáb
is-leap       : False
locale        : ar
strftime      : 0183-10-07 Kamál 'Izzat

round trip    : 2026-09-14   exact : True
```

`cycle-year-name` is the name that year carries within its nineteen-year
cycle, which has no analogue in the Gregorian calendar at all.

## The epoch

```raku name="epoch"
use Date::Calendar::Bahai;

for '1844-03-21', '1900-01-01', '2000-01-01' -> $d {
    my $b = Date::Calendar::Bahai.new-from-date(Date.new($d));
    say sprintf('%s -> %s   back=%s exact=%s',
        $d, $b.gist, $b.to-date, $b.to-date == Date.new($d));
}
say '';
my $r = try Date::Calendar::Bahai.new-from-date(Date.new('1844-03-20'));
say 'the day before the epoch : ', $! ?? 'refused' !! 'accepted';
```

```output
1844-03-21 -> 0001-01-01   back=1844-03-21 exact=True
1900-01-01 -> 0056-16-02   back=1900-01-01 exact=True
2000-01-01 -> 0156-16-02   back=2000-01-01 exact=True

the day before the epoch : refused
```

21 March 1844 is Baháʼí 0001-01-01. The calendar begins there.

## The one thing to know

The Baháʼí year here has **twenty** months, and month 19 is not the one you
want.

```raku name="twenty-trap"
use Date::Calendar::Bahai;

say 'month 19 : ', Date::Calendar::Bahai.new(year => 183, month => 19, day => 1).month-name;
say 'month 20 : ', Date::Calendar::Bahai.new(year => 183, month => 20, day => 1).month-name;
say '';
say 'everyone knows this calendar as "19 months of 19 days".';
say 'the intercalary period Ayyám-i-Há gets its own month number, 19,';
say 'which pushes the real nineteenth month out to 20.';
say '';
for 181, 183, 184 -> $y {
    my $len = (1..5).grep({
        (try Date::Calendar::Bahai.new(year => $y, month => 19, day => $_)).defined
    }).elems;
    say sprintf('  year %d: leap=%-5s  Ayyám-i-Há is %d days',
        $y, Date::Calendar::Bahai.new(year => $y, month => 1, day => 1).is-leap, $len);
}
```

```output
month 19 : Ayyám-i-Há
month 20 : 'Alá

everyone knows this calendar as "19 months of 19 days".
the intercalary period Ayyám-i-Há gets its own month number, 19,
which pushes the real nineteenth month out to 20.

  year 181: leap=False  Ayyám-i-Há is 4 days
  year 183: leap=False  Ayyám-i-Há is 4 days
  year 184: leap=True   Ayyám-i-Há is 5 days
```

So `.month` ranges over 1 to 20, month 19 is four or five days long depending
on the year, and indexing `'Alá` — the nineteenth month of the nineteen — as
19 lands you on Ayyám-i-Há instead.

## Arithmetic against astronomical

```raku name="variants"
use Date::Calendar::Bahai;
use Date::Calendar::Bahai::Astronomical;

for '2026-09-14', '2022-03-01', '2020-06-01' -> $d {
    my $g = Date.new($d);
    my $a = Date::Calendar::Bahai.new-from-date($g).gist;
    my $s = Date::Calendar::Bahai::Astronomical.new-from-date($g).gist;
    say sprintf('%s  arithmetic=%s  astronomical=%s  %s',
        $d, $a, $s, $a eq $s ?? 'agree' !! 'DIFFER');
}
```

```output
2026-09-14  arithmetic=0183-10-07  astronomical=0183-10-07  agree
2022-03-01  arithmetic=0178-19-04  astronomical=0178-19-05  DIFFER
2020-06-01  arithmetic=0177-04-16  astronomical=0177-04-17  DIFFER
```

The two classes disagree for **years at a stretch**, not the odd day: over
2020 to 2028 they differ on 1,462 consecutive days, from March 2020 to March
2026. Picking the wrong class shifts your date by a day for four solid years.

State which reckoning you are using, and stick to it.

## Where the two engines differ

On the exception a bad month or day produces. Every class in this family
validates twice, with a `where` constraint on the attribute and an explicit
range check in `BUILD`. Rakudo reaches `BUILD` and reports `Month out of
range. Is: 21, should be in 1..20`; Raku++ fills the attribute from the named
argument first, so the `where` fires and you get an `X::TypeCheck::Assignment`
with no range in it.

Both refuse the date; only one is informative.

One more thing that is not an engine difference: `after-sunset` advances the
Baháʼí date but not the Gregorian one, so a date built with that daypart gists
one day later while `to-date` returns the same Gregorian day.
