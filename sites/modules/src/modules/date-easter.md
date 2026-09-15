---
name: Date::Easter
version: 0.0.5
auth: zef:tbrowder
kind: Distribution · calendars
summary: Gregorian Easter Sunday from a year, and the six moveable feasts
  anchored to it, as Date::Event objects keyed by the date each falls on.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Date::Event
raku-land: https://raku.land/zef:tbrowder/Date::Easter
source: https://github.com/tbrowder/Date-Easter.git
---

## What it is for

Easter is the one date in the Western calendar that cannot be looked up in a
table: it is the first Sunday after the first full moon on or after the spring
equinox, and computing it needs the Calendar-FAQ arithmetic that every
almanac reimplements.

Six other feasts hang off it — Ash Wednesday, Palm Sunday, Good Friday,
Ascension, Pentecost — so a scheduling system that knows Easter knows the
whole moveable half of the liturgical year.

## Computing Easter

```raku name="easter"
use Date::Easter;

my @check = 1818 => '1818-03-22', 2000 => '2000-04-23', 2016 => '2016-03-27',
            2020 => '2020-04-12', 2024 => '2024-03-31', 2026 => '2026-04-05',
            2038 => '2038-04-25';

for @check -> $p {
    my $e = Easter($p.key);
    say sprintf('%d  computed=%s  published=%s  %s  (%s)',
        $p.key, $e.Str, $p.value,
        $e.Str eq $p.value ?? 'match' !! 'DIFFERS',
        $e.day-of-week == 7 ?? 'Sunday' !! 'NOT SUNDAY');
}
```

```output
1818  computed=1818-03-22  published=1818-03-22  match  (Sunday)
2000  computed=2000-04-23  published=2000-04-23  match  (Sunday)
2016  computed=2016-03-27  published=2016-03-27  match  (Sunday)
2020  computed=2020-04-12  published=2020-04-12  match  (Sunday)
2024  computed=2024-03-31  published=2024-03-31  match  (Sunday)
2026  computed=2026-04-05  published=2026-04-05  match  (Sunday)
2038  computed=2038-04-25  published=2038-04-25  match  (Sunday)
```

1818 and 2038 are the two extremes: Easter can fall no earlier than 22 March
and no later than 25 April, and both bounds are actually attained.

## The invariants

```raku name="invariants"
use Date::Easter;

my ($bad-dow, $bad-range, $min, $max) = 0, 0, 'zz-zz', '';
for 1583 .. 2200 -> $y {
    my $e = Easter($y);
    $bad-dow++ unless $e.day-of-week == 7;
    my $md = $e.Str.substr(5);
    $bad-range++ unless '03-22' le $md le '04-25';
    $min = $md if $md lt $min;
    $max = $md if $md gt $max;
}
say 'years checked   : ', 2200 - 1583 + 1;
say 'non-Sundays     : ', $bad-dow;
say 'out of 03-22..04-25 : ', $bad-range;
say 'earliest seen   : ', $min;
say 'latest seen     : ', $max;
```

```output
years checked   : 618
non-Sundays     : 0
out of 03-22..04-25 : 0
earliest seen   : 03-22
latest seen     : 04-25
```

Six hundred and eighteen consecutive years, always a Sunday, always inside the
published window, and both extremes reached.

## The moveable feasts

```raku name="feasts"
use Date::Easter;

my $h := get-easter-events-hashlist(:year(2025));

say 'return type : ', $h.^name;
say 'keyed by    : ', $h.keyof.^name;
say '';
for $h.keys.sort -> $d {
    for $h{$d}.list -> $e {
        say sprintf('%s  %-14s %s', $d, $e.short-name, $e.name);
    }
}
```

```output
return type : Hash[Array,Date]
keyed by    : Date

2025-03-05  Ash Wed.       Ash Wednesday
2025-04-13  Palm Sun.      Palm Sunday
2025-04-18  Good Fri.      Good Friday
2025-04-20  Easter         Easter Sunday
2025-05-30  Ascension D.   Ascension Day
2025-06-09  Pentecost      Pentecost
```

Each value is an `Array` of `Date::Event`, with `.name`, `.short-name`,
`.date` and `.Etype`. The `Etype` renders as `Liturgy`.

## The one thing to know

The hash is keyed by **`Date` objects**, and assigning it to an ordinary
`my %h` silently destroys that.

```raku name="keyof-trap"
use Date::Easter;

my $bound := get-easter-events-hashlist(:year(2025));
say 'bound with :=';
say '  type  : ', $bound.^name;
say '  keyof : ', $bound.keyof.^name;
say '  index by a Date object : ', $bound{Date.new(2025, 4, 20)}[0].name;

my %copied = get-easter-events-hashlist(:year(2025));
say '';
say 'assigned to my %h';
say '  type  : ', %copied.^name;
say '  keyof : ', %copied.keyof.^name;
say '  index by a string      : ', %copied{'2025-04-20'}[0].name;
```

```output
bound with :=
  type  : Hash[Array,Date]
  keyof : Date
  index by a Date object : Easter Sunday

assigned to my %h
  type  : Hash
  keyof : Str(Any)
  index by a string      : Easter Sunday
```

The lossy step is invisible — nothing warns — and afterwards the two forms
behave *oppositely* under a string subscript: the bound one refuses it, the
copied one accepts it. Bind with `:=`, or declare the receiver as
`my Array %h{Date}`.

The second thing in the same area: `:year` has **no default**. Omitting it
propagates an undefined value into `Easter`'s `Int` parameter, which is a
runtime type error rather than a helpful message.

## Where the two engines differ

Twice, and both are cases where Rakudo is stricter.

Indexing the `Date`-keyed object hash with a **string** succeeds on Raku++ and
correctly throws `Type check failed in binding to parameter 'key'; expected
Date but got Str` on Rakudo. And calling `get-easter-events-hashlist()` with
**no `:year`** dies on Rakudo with a type-check failure, while Raku++ silently
answers for year 0.

Neither affects correct use, and every example above is written so both
engines agree.

One thing that is not an engine difference and is worth noticing: `Easter` is
strictly `Int`. `Easter("2025")` and `Easter(2025.0)` both throw on both
engines — which is the exact opposite of `Date::Christian::Advent`, whose year
parameter is untyped and will silently accept `Nil`.
