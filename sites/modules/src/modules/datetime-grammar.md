---
name: DateTime::Grammar
version: 0.1.3
auth: zef:antononcube
kind: Distribution · time
summary: A DateTime from a dozen conventional date shapes — ISO 8601, the
  three HTTP formats, slashed numeric dates and spelled-out months — as a
  grammar factored into a reusable role.
status: divergent
suite: 4 files, green
tested: 2026-09-15
license: MIT
raku-land: https://raku.land/zef:antononcube/DateTime::Grammar
source: https://github.com/antononcube/Raku-DateTime-Grammar
---

## What it is for

Dates arrive written the way whoever produced them felt like writing them:
an HTTP header in one format, a cookie in an older one, a C program's log
in a third, a spreadsheet export in a fourth. `DateTime.new` understands
exactly one of these. A program reading real-world input needs the rest.

This distribution is a grammar covering about a dozen shapes, with actions
that build a `DateTime`, and it is factored so the grammar is a role you
can mix into a larger grammar of your own rather than a closed parser.

## A dozen shapes

```raku name="shapes"
use DateTime::Grammar;

for '2026-09-14',
    '2026-09-14T12:30:45Z',
    'Mon, 14 Sep 2026 12:30:45 GMT',
    'Mon Sep 14 12:30:45 2026',
    'September 14, 2026',
    '14 September 2026',
    '09/14/2026' -> $text
{
    say sprintf('%-32s %s', "'$text'", datetime-interpret($text));
}

say datetime-interpret('not a date at all').raku;
say datetime-parse('2026-09-14').defined;
say datetime-subparse('2026-09-14 and then some junk').Str;
```

```output
'2026-09-14'                     2026-09-14T00:00:00Z
'2026-09-14T12:30:45Z'           2026-09-14T12:30:45Z
'Mon, 14 Sep 2026 12:30:45 GMT'  2026-09-14T12:30:45Z
'Mon Sep 14 12:30:45 2026'       2026-09-14T12:30:45Z
'September 14, 2026'             2026-09-14T00:00:00Z
'14 September 2026'              2026-09-14T00:00:00Z
'09/14/2026'                     2026-09-14T00:00:00Z
Nil
True
2026-09-14
```

`datetime-interpret` gives you the `DateTime`, `datetime-parse` the raw
match — useful when you want to know *which* rule fired — and
`datetime-subparse` matches a prefix and leaves the rest, which is what you
want when the date is at the start of a log line.

Text none of the grammars accept comes back as an undefined value rather
than throwing, so the result always needs testing.

## The one thing to know

Two-digit years are taken literally, with no pivot:

```raku name="two-digit-years"
use DateTime::Grammar;

say datetime-interpret('Monday, 14-Sep-26 00:00:00 GMT');
say datetime-interpret('14-Sep-99');
say datetime-interpret('14-Sep-00');
say datetime-interpret('Fri, 14 Sep 2026 00:00:00 GMT');
say Date.new('2026-09-14').day-of-week;
```

```output
0026-09-14T00:00:00Z
0099-09-14T00:00:00Z
0000-09-14T00:00:00Z
2026-09-14T00:00:00Z
1
```

`14-Sep-26` is the year twenty-six, not 2026 — a valid-looking `DateTime`
two millennia out, which then sorts, compares and formats without
complaint. That format is RFC 850, it was obsolete before this module was
written, and it still turns up in cookies from old servers. If you read
those, check for `.year < 100` and add the century by RFC 6265's rule
yourself.

The last two lines are a second, smaller surprise: the weekday name is
parsed and never validated. `Fri, 14 Sep 2026` is accepted and yields the
14th, which was a Monday. If the weekday is your only check that a date
survived transmission intact, it is not checking anything.

## Where the two engines differ

Failure modes are inconsistent in a way the engines then disagree about.
Unrecognised text returns an undefined value, but text that is recognised
and impossible — `2026-02-30`, or a day-first date like `14/09/2026`, which
this grammar reads as month 14 — throws. Under Raku++ the exception is
`X::OutOfRange`; under Rakudo it is `X::Temporal::OutOfRange`, and the two
do not smartmatch as each other. A `CATCH` written against the Rakudo name
will not fire on Raku++.

So a call needs both a definedness test and a `try`, and the `try` should
catch on the base `Exception` rather than on either name.

One more thing about slashed dates, since it is a silent wrong answer
rather than a loud one: they are read month-first, so `09/14/2026` is the
14th of September and `14/09/2026` throws. A day-first date whose day
happens to be twelve or less is read as the wrong date with no error at
all.
