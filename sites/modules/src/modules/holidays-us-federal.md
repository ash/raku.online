---
name: Holidays::US::Federal
version: 0.0.5
auth: zef:tbrowder
kind: Distribution · calendars
summary: The eleven US federal holidays for a year, with the date each is
  observed when the holiday falls on a weekend.
status: full
suite: 4 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: UUID::V4, Text::Utils, Date::Event, Date::Utils
raku-land: https://raku.land/zef:tbrowder/Holidays::US::Federal
source: https://github.com/tbrowder/Holidays-US-Federal.git
---

## What it is for

A payroll run, a delivery estimate or a business-day calculation in the United
States needs the federal holiday list — and, crucially, the **observed** date,
which is not the same thing. A holiday on a Saturday is observed the Friday
before; one on a Sunday, the Monday after.

Getting the shift right is the part that is easy to forget and expensive to
get wrong.

## A year of holidays

```raku name="holidays"
use Holidays::US::Federal;

my %h = get-fedholidays(:year(2021), :set-id('S'));

for %h.keys.sort -> $date {
    for %h{$date}.keys.sort -> $key {
        my $e = %h{$date}{$key};
        say sprintf('%s  %-3s  observed %s  %s',
            ~$e.date,
            <Mon Tue Wed Thu Fri Sat Sun>[$e.date.day-of-week - 1],
            ~$e.date-observed, $e.name);
    }
}
```

```output
2021-01-01  Fri  observed 2021-01-01  New Year's Day
2021-01-18  Mon  observed 2021-01-18  Birthday of Martin Luther King, Jr.
2021-02-15  Mon  observed 2021-02-15  Washington's Birthday
2021-05-31  Mon  observed 2021-05-31  Memorial Day
2021-06-19  Sat  observed 2021-06-18  Juneteenth National Independence Day
2021-07-04  Sun  observed 2021-07-05  Independence Day
2021-09-06  Mon  observed 2021-09-06  Labor Day
2021-10-11  Mon  observed 2021-10-11  Columbus Day
2021-11-11  Thu  observed 2021-11-11  Veterans Day
2021-11-25  Thu  observed 2021-11-25  Thanksgiving Day
2021-12-25  Sat  observed 2021-12-24  Christmas Day
```

Look at Juneteenth, Independence Day and Christmas in that list. 2021 put
Juneteenth and Christmas on a Saturday, both observed the Friday before, and
Independence Day on a Sunday, observed the Monday after. That is the whole
reason to use a library rather than a table.

## Counting the shifts

```raku name="count"
use Holidays::US::Federal;

for 2021, 2024, 2026 -> $y {
    my %h = get-fedholidays(:year($y), :set-id('X'));
    my @shifted = %h.keys.grep({
        %h{$_}.values[0].date ne %h{$_}.values[0].date-observed
    });
    say sprintf('%d : %2d holidays, %d observed on a different day',
        $y, %h.elems, @shifted.elems);
}
```

```output
2021 : 11 holidays, 3 observed on a different day
2024 : 11 holidays, 0 observed on a different day
2026 : 11 holidays, 1 observed on a different day
```

## The one thing to know

The return value is a **hash of hashes**, and `:set-id` never reaches the
object.

```raku name="shape-trap"
use Holidays::US::Federal;

my %h = get-fedholidays(:year(2024), :set-id('MYSET'));

say 'the outer keys are dates : ', %h.keys.sort.head(3).join(' ');
say '';
say 'each value is another HASH, not a holiday:';
say '  %h{"2024-07-04"} is a ', %h{'2024-07-04'}.^name;
say '  its keys           : ', %h{'2024-07-04'}.keys.join(' ');
say '';
my $e = %h{'2024-07-04'}{'MYSET|jul4'};
say 'the holiday is two subscripts down : ', $e.name;
say '';
say 'and the set id you passed is nowhere on it:';
say '  $e.set-id is the empty string : ', $e.set-id eq '';
```

```output
the outer keys are dates : 2024-01-01 2024-01-15 2024-02-19

each value is another HASH, not a holiday:
  %h{"2024-07-04"} is a Hash
  its keys           : MYSET|jul4

the holiday is two subscripts down : Independence Day

and the set id you passed is nowhere on it:
  $e.set-id is the empty string : True
```

`%h{$date}.name` gives you `No such method 'name' for invocant of type
'Hash'`, which is the error everyone meets first. The mandatory `:set-id`
exists only to prefix that inner key; the `FedHoliday.set-id` attribute is
left empty.

Write `%h{$date}.values[0]` if you only ever pass one set id, as the counting
example above does.

## Where the two engines differ

Only in the exception type for a missing required named argument —
`X::Parameter::RequiredNamed` on Raku++, `X::AdHoc` on Rakudo, both carrying
the text `Required named parameter 'set-id' not passed`.

The thing that is **not** an engine difference, and that will produce
confidently wrong answers, is that there is **no year validation at all**:

```raku name="no-validation"
use Holidays::US::Federal;

for 1776, 1600 -> $y {
    my %h = get-fedholidays(:year($y), :set-id('S'));
    my $june = %h.keys.first({ %h{$_}.values[0].name.contains('Juneteenth') });
    say sprintf('%d : %d holidays returned, including Juneteenth on %s', $y, %h.elems, $june);
}
say '';
say 'Juneteenth became a federal holiday in 2021.';
```

```output
1776 : 11 holidays returned, including Juneteenth on 1776-06-19
1600 : 11 holidays returned, including Juneteenth on 1600-06-19

Juneteenth became a federal holiday in 2021.
```

Every year from the Gregorian reform onwards returns the full modern list.
Anything doing historical date work gets eleven holidays for 1776 and believes
them. Guard the year yourself.

There is no Inauguration Day entry in any year, and the `.raku` rendering of
the embedded `Date` differs between engines — relevant only if you serialise
these objects.
