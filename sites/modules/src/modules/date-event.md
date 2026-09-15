---
name: Date::Event
version: 0.0.12
auth: zef:tbrowder
kind: Distribution · time
summary: One record type for "something that happens on a date" — a name, a
  category from a sixteen-value enumeration, the date, the observed date,
  and an identifier scoped to a set.
status: full
suite: 5 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: JSON::Fast, UUID::V4
raku-land: https://raku.land/zef:tbrowder/Date::Event
source: https://github.com/tbrowder/Date-Event
---

## What it is for

A calendar program has one central noun and it is surprisingly awkward: a
thing that happens on a date. It needs a name and a short name, because the
grid cell is narrow. It needs a category, so that public holidays can be
coloured differently from birthdays. It needs *two* dates, because a
holiday falling on a Sunday is observed on the Monday and both matter. And
it needs an identifier that is unique within a set of events but not
globally, because the American federal holidays and your family's birthdays
are two sets that should not collide.

This distribution is that record, with the sixteen-value category
enumeration already written.

## An event

```raku name="event"
use Date::Event;

my $labor-day = Date::Event.new(
    :set-id('us-federal'),
    :id('labor-day'),
    :name('Labor Day'),
    :short-name('Labor'),
    :Etype(EType::Holiday),
    :date(Date.new('2026-09-07')),
    :date-observed(Date.new('2026-09-07')),
    :notes('first Monday in September'),
    :is-calculated(True),
);

say $labor-day.name, ' / ', $labor-day.short-name;
say $labor-day.set-id, ' ', $labor-day.id;
say $labor-day.Etype, ' = ', $labor-day.Etype.value;
say $labor-day.date, ' observed ', $labor-day.date-observed;
say $labor-day.is-calculated;
say EType.enums.sort(*.value).map(*.key).join(' ');
```

```output
Labor Day / Labor
us-federal labor-day
Holiday = 100
2026-09-07 observed 2026-09-07
True
Unknown Birth Christening Baptism BarMitzvah BatMitzvah Graduation Wedding Anniversary Retirement Death Birthday Liturgy Holiday Astro Other
```

The categories run from `Birth` and `Wedding` through `Liturgy` to
`Holiday` and `Astro`, with deliberate gaps in the numbering so more can be
added without renumbering. `is-calculated` marks an event whose date comes
from a rule rather than a fixed day, which is what tells a renderer it must
be recomputed for each year.

`date-observed` is **not** defaulted from `date`. Leave it out and it stays
undefined, which is a reasonable choice — it forces the question — and a
surprise if you assumed otherwise.

## The one thing to know

`make-gid` takes its two arguments in one order and builds the string in
the other:

```raku name="gid-order"
use Date::Event;

my $gid = Date::Event.make-gid(:set-id('us-federal'), :id('labor-day'));
say $gid;
say $gid.split('|').join(' then ');
```

```output
labor-day|us-federal
labor-day then us-federal
```

You pass the set first and the identifier second; what comes out is the
identifier first and the set second. Anyone who builds the string by hand
as `"$set-id|$id"`, or who unpacks it as `(set-id, id)`, gets the pair the
wrong way round — and both halves are strings, so nothing complains.

The companion `split-gid` is worse than merely reversed: it cannot be
called at all under Rakudo. It is declared to return a `List` and returns a
`Seq`, and Rakudo type-checks a declared return value where Raku++ does
not. So the method appears to work on one engine and throws on the other,
and splitting the string yourself — as the example does — is the portable
move.

Two smaller things worth knowing. `attr-info`, which numbers the record's
attributes, returns them keyed by *strings*, so the default sort gives
0, 1, 10, 11, … and you want `.sort(+*)` to walk them in declaration order.
And the six subs in the `Date::Utilities` unit that ships alongside — the
CSV and JSON importers and exporters — are empty stubs that take no
arguments and return an undefined value.
