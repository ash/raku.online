---
name: Swedish::TextDates_sv
version: 0.1.2
auth: github:svekenfur
kind: Distribution · localisation
summary: Swedish dates spelled out — "tolfte juli 2017" or "12 juli 2017" —
  plus weekday names, returned as enum elements rather than strings.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:svekenfur/Swedish::TextDates_sv
source: https://github.com/svekenfur/Swedish-TextDates_sv.git
---

## What it is for

Turning `2017-07-12` into prose a Swede would read: *tolfte juli 2017* in the
ordinal "fancy" form, *12 juli 2017* in the numeral "formal" one. It also
turns a weekday number into its Swedish name, long or short.

The input is always a `yyyy-mm-dd` string. Month, day-of-month and weekday
ranges are validated, February included, leap years and all.

## Spelling a date out

```raku name="dates"
use Swedish::TextDates_sv;

for '2017-07-12', '2020-02-29', '2024-12-01', '2017-1-2' -> $d {
    my $w = Whole-Date-Names_sv.new(whole_date => $d);
    say sprintf('%-12s fancy: %-28s formal: %s',
                $d, $w.fancy-date.join(' '), $w.formal-date.join(' '));
}
say '';
say 'single-digit fields are accepted, so the format is looser than';
say 'yyyy-mm-dd suggests.';
```

```output
2017-07-12   fancy: tolfte juli 2017             formal: 12 juli 2017
2020-02-29   fancy: tjugonionde februari 2020    formal: 29 feb 2020
2024-12-01   fancy: första december 2024         formal: 1 dec 2024
2017-1-2     fancy: andra januari 2017           formal: 2 jan 2017

single-digit fields are accepted, so the format is looser than
yyyy-mm-dd suggests.
```

## Weekday names

```raku name="weekdays"
use Swedish::TextDates_sv;

for 1 .. 7 -> $n {
    my $d = Day-Of-Week-Name_sv.new(day_of_week_number => $n);
    say sprintf('  %d  %-9s %s', $n, $d.get-day-name_sv, $d.get-day-name-short_sv);
}
```

```output
  1  måndag    mån
  2  tisdag    tis
  3  onsdag    ons
  4  torsdag   tors
  5  fredag    fre
  6  lördag    lör
  7  söndag    sön
```

## What comes back is not a Str

```raku name="types"
use Swedish::TextDates_sv;

my $w = Whole-Date-Names_sv.new(whole_date => '2017-07-12');
my @fancy  = $w.fancy-date;
my @formal = $w.formal-date;

say 'fancy-date[0]  : ', @fancy[0].raku,  '  .WHAT = ', @fancy[0].WHAT.^name;
say '  ~~ Str       : ', @fancy[0] ~~ Str;
say '  eq works     : ', @fancy[0] eq 'tolfte';
say '  === does not : ', @fancy[0] === 'tolfte';
say '  .Int         : ', @fancy[0].Int;
say '';
say 'formal-date[1] : ', @formal[1].raku, '  .WHAT = ', @formal[1].WHAT.^name;
say '';
say 'the two methods on the same class have different return shapes:';
say 'fancy-date gives enum elements, formal-date a plain Str for the month.';
say 'and the enum types are NOT exported, so you cannot name them to';
say 'smart-match against. Use `eq`, or call .Str.';
```

```output
fancy-date[0]  : day_of_month_name_sv::tolfte  .WHAT = day_of_month_name_sv
  ~~ Str       : False
  eq works     : True
  === does not : False
  .Int         : 12

formal-date[1] : "juli"  .WHAT = Str

the two methods on the same class have different return shapes:
fancy-date gives enum elements, formal-date a plain Str for the month.
and the enum types are NOT exported, so you cannot name them to
smart-match against. Use `eq`, or call .Str.
```

## The one thing to know

An invalid date does not throw. It writes one line to stderr and calls
`exit` — and `exit` with no argument means status **0**. Your process dies
mid-program and the shell sees success.

```raku name="exit"
use Swedish::TextDates_sv;

say 'about to ask for 2017-02-30, which does not exist.';
say 'if you see the line after this one, the module did not abort.';
say '';
say '(it does abort. `try`, CATCH and LEAVE are all powerless — this is';
say 'exit, not an exception, and the status is 0, so a shell script or a';
say 'CI job sees a clean run with truncated output.)';
say '';
say 'validate before you call:';
for '2017-02-30', '2017-13-01', '2020-02-29' -> $s {
    my ($y, $m, $d) = $s.split('-')>>.Int;
    my $ok = try { Date.new($y, $m, $d); True };
    say sprintf('  %-12s %s', $s, $ok ?? 'a real date' !! 'refuse it yourself');
}
```

```output
about to ask for 2017-02-30, which does not exist.
if you see the line after this one, the module did not abort.

(it does abort. `try`, CATCH and LEAVE are all powerless — this is
exit, not an exception, and the status is 0, so a shell script or a
CI job sees a clean run with truncated output.)

validate before you call:
  2017-02-30   refuse it yourself
  2017-13-01   refuse it yourself
  2020-02-29   a real date
```

`Date.new` is the guard the module does not have: it raises a catchable
exception for exactly the inputs that would abort your process.

## Where the two engines differ

Nothing now. Until Raku++ 3.28.0 this module answered **onsdag for Thursday
and trettonde for twelve** under Raku++, silently — its weekday and
day-of-month tables are declared with non-ASCII colonpair keys
(`«:måndag(1) tisdag onsdag»`), and the word-quote reader demanded an ASCII
identifier, so the whole token `:måndag(1)` became a literal key at ordinal 0
and every later name shifted down by one. The month table is pure ASCII,
which is why months were the one part that survived and the bug was hard to
see.

```raku name="enum"
my enum Weekday «:måndag(1) tisdag onsdag torsdag»;
say 'a non-ASCII colonpair key seeds the enum:';
for Weekday.enums.sort(*.value) -> $p {
    say sprintf('  %-9s %d', $p.key, $p.value);
}
```

```output
a non-ASCII colonpair key seeds the enum:
  måndag    1
  tisdag    2
  onsdag    3
  torsdag   4
```

Two divergences remain, and both are Raku++ being more permissive than the
module expects. A typed public attribute is not type-checked against a named
constructor argument there, so `whole_date => Date.new(2017,7,12)` builds a
broken object under Raku++ where Rakudo throws; and `Str:U.Int` returns `0`
under Raku++ where Rakudo refuses, which is why a wrong separator
(`'2017/07/12'`) produces the misleading "only twelve months in a year" on one
engine and a raw internal type error on the other. Pass a `Str` in the
documented format and neither can reach you.

One naming note: the unit is declared `unit module TextDates_sv`, so
`use Swedish::TextDates_sv` installs a package under a different name than the
distribution. The two exported classes are what you want; the four enums and
three check subs are not exported.
