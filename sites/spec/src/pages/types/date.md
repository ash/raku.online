---
title: Date & DateTime
slug: date
status: full
order: 90
summary: Calendar dates and wall-clock timestamps, with arithmetic and field access.
---

`Date` is a calendar day (year, month, day); `DateTime` adds a wall-clock time and a
time zone. Both are immutable value types with rich field accessors and calendar-aware
arithmetic — subtracting two dates gives a day count, and `.later`/`.earlier` shift by
calendar units that respect month and year lengths.

## Building a Date and reading its fields

Construct from parts or from an ISO `YYYY-MM-DD` string; the accessors give each
field back.

```raku
my $d = Date.new(2026, 7, 20);
say $d;
say $d.day-of-week;
say $d.month;
```
```output
2026-07-20
1
7
```

`.day-of-week` is `1` for Monday through `7` for Sunday, so 2026-07-20 is a Monday.
The stringification is always ISO `YYYY-MM-DD`.

## Calendar accessors

A `Date` answers the usual calendar questions directly — its position in the year, the
length of its month, and whether its year is a leap year.

```raku
my $d = Date.new(2024, 2, 29);
say $d.day-of-year;
say $d.days-in-month;
say $d.is-leap-year;
```
```output
60
29
True
```

2024-02-29 is the 60th day of a leap year, and February that year has 29 days.

There are week-based accessors too: `.week` returns the ISO `(year, week-number)`
pair, `.week-year` just the ISO year, and `.weekday-of-month` which weekday-occurrence
this is (e.g. the 3rd Tuesday).

```raku
my $d = Date.new(2026, 7, 21);
say $d.week;
say $d.week-year;
say $d.weekday-of-month;
```
```output
(2026 30)
2026
3
```

2026-07-21 falls in ISO week 30, and it's the 3rd Tuesday of the month.

## Date arithmetic

Subtracting two `Date`s yields the number of days between them; `.later` and
`.earlier` shift by named units.

```raku
say Date.new("2026-12-25") - Date.new("2026-07-20");
my $d = Date.new(2026, 1, 31);
say $d.later(:1month);
say $d.truncated-to("month");
```
```output
158
2026-02-28
2026-01-01
```

`.later(:1month)` on the 31st of January lands on `2026-02-28` — the shift is
calendar-aware and clamps to the last valid day. `.truncated-to("month")` snaps back
to the first of the month.

## DateTime — adding a clock

`DateTime` carries hour/minute/second on top of the date, and can hand back just the
`Date` or a formatted time.

```raku
my $dt = DateTime.new(2026, 7, 20, 14, 30, 15);
say $dt.hour;
say $dt.minute;
say $dt.second;
say $dt.Date;
say $dt.hh-mm-ss;
```
```output
14
30
15
2026-07-20
14:30:15
```

A time zone is an `:timezone` offset in seconds; `.offset` reads it back and `.utc`
converts.

```raku
my $dt = DateTime.new(2026, 7, 20, 14, 0, 0, timezone => 3600);
say $dt.offset;
say $dt.utc.hour;
```
```output
3600
13
```

## Notes

- `Date.today` gives the current date; `DateTime.now` the current timestamp — both
  non-deterministic, so they aren't shown here.
- Useful `Date` accessors: `.year`, `.month`, `.day`, `.day-of-week`,
  `.day-of-year`, `.days-in-month`, `.is-leap-year`.
- `.later`/`.earlier` accept `:Ndays`, `:Nweeks`, `:Nmonths`, `:Nyears` (and
  `DateTime` also `:Nhours`/`:Nminutes`/`:Nseconds`).
- A `DateTime` minus a `DateTime` is a `Duration` (a number of seconds); a `Date`
  minus a `Date` is a plain `Int` day count.
- `.truncated-to(unit)` rounds a date or timestamp down to `"day"`, `"month"`,
  `"year"`, `"hour"`, etc. — handy for bucketing.
