---
name: Date::Utils
version: 0.7.0
auth: zef:tbrowder
kind: Distribution · time
summary: The arithmetic a month-grid calendar needs — which weekday column
  the first falls in, how many rows the month takes, and where "third
  Monday in January" actually lands.
status: full
suite: 7 files, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:tbrowder/Date::Utils
source: https://github.com/tbrowder/Date-Utils
---

## What it is for

Drawing a month as a grid is a handful of small sums that are all easy to
get wrong by one: which column the first of the month goes in, how many
days the first partial week holds, how many rows the whole month needs, and
whether the week starts on Sunday or Monday. Separately, half the holidays
in any country are defined by a rule rather than a date — the first Monday
in September, the last Monday in May, the fourth Thursday in November — and
turning those rules into dates is the same kind of fiddly.

This distribution is both, with weekdays numbered 1 to 7 as Raku's own
`Date.day-of-week` numbers them, so nothing has to be translated.

## Holidays from their rules

```raku name="rules"
use Date::Utils;

say nth-dow-in-month(:year(2026), :month(9),  :nth(1),  :dow(1));
say nth-dow-in-month(:year(2026), :month(1),  :nth(3),  :dow(1));
say nth-dow-in-month(:year(2026), :month(11), :nth(4),  :dow(4));
say nth-dow-in-month(:year(2026), :month(5),  :nth(-1), :dow(1));

my $base = Date.new('2026-09-14');
say dow-name($base.day-of-week);
say nth-dow-after-date(:date($base), :nth(1), :dow(5));
say nth-dow-after-date(:date($base), :nth(2), :dow(5));
```

```output
2026-09-07
2026-01-19
2026-11-26
2026-05-25
Monday
2026-09-18
2026-09-25
```

`:nth(-1)` is "the last one in the month", which is how Memorial Day is
defined and the only way to express it without knowing the month's length.
`nth-dow-after-date` asks the same question relative to a date instead of a
month.

## Laying out a grid

```raku name="grid"
use Date::Utils;

my $first = Date.new('2026-09-01');
say dow-name($first.day-of-week);

for 7, 1 -> $starts-on {
    say dow-name($starts-on), ' calendar:';
    say '  columns  ', days-of-week($starts-on).map({ dow-name($_).substr(0, 3) }).join(' ');
    say '  1 Sep in column ', day-index-in-week($first.day-of-week, :cal-first-dow($starts-on));
    say '  week 1 holds ', days-in-week1($first.day-of-week, :cal-first-dow($starts-on)), ' days';
    say '  rows needed  ', weeks-in-month($first, :cal-first-dow($starts-on));
}
```

```output
Tuesday
Sunday calendar:
  columns  Sun Mon Tue Wed Thu Fri Sat
  1 Sep in column 2
  week 1 holds 5 days
  rows needed  5
Monday calendar:
  columns  Mon Tue Wed Thu Fri Sat Sun
  1 Sep in column 1
  week 1 holds 6 days
  rows needed  5
```

`days-of-week` returns the column order, and everything else takes the same
`:cal-first-dow` so one setting drives the whole layout. The default is 7,
Sunday first, which is the American convention rather than Raku's own
Monday-first numbering.

## The one thing to know

`:nth(-1)` means "the last one" in the month-based routine and means
nothing at all in the date-based one, where it is neither honoured nor
refused:

```raku name="negative-nth"
use Date::Utils;

my $base = Date.new('2026-09-14');
for 2, 1, 0, -1, -2 -> $n {
    say $n, ' -> ', nth-dow-after-date(:date($base), :nth($n), :dow(7));
}
say nth-dow-after-date(:date($base), :nth(10), :dow(7));
```

```output
2 -> 2026-09-27
1 -> 2026-09-20
0 -> 2026-11-22
-1 -> 2026-11-22
-2 -> 2026-11-22
2026-11-22
```

Zero and every negative value collapse to the same date, and it is the one
`:nth(10)` gives — ten Sundays *forward*, not any number of Sundays back.
The two routines read as a symmetric pair and are not one. There is no
"previous Sunday" here; subtract from the date yourself.

One more silent answer to know about: asking for a fifth Monday in a month
that has four returns the fourth rather than failing, so a rule that cannot
be satisfied produces a plausible wrong date instead of an error.
