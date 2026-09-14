---
name: Date::Calendar::Strftime
version: 0.1.1
auth: zef:jforget
kind: Distribution · time
summary: The C library's `strftime` as a role — `%Y-%m-%d`, `%j`, `%V`,
  widths and flags — mixed into a core Date or into any of the author's
  Date::Calendar classes, so one format string works across calendars.
status: full
suite: 4 files, green
tested: 2026-09-14
license: Artistic-2.0
depends: Date::Names
raku-land: https://raku.land/zef:jforget/Date::Calendar::Strftime
source: https://github.com/jforget/raku-Date-Calendar-Strftime
---

## What it is for

Raku's `Date` formats itself one way, `2026-09-14`, and every other layout —
`14/09/2026`, day-of-year, ISO week — is a `sprintf` you write by hand. The
C world settled this long ago with `strftime` and its `%` codes, which a
generation of programmers already know. This distribution is that
vocabulary as a Raku role: mix it into a `Date` and it gains a `strftime`
method. It is the formatting layer under the author's family of calendar
modules (Hebrew, Coptic, French Revolutionary and a dozen more), which is
why it is a role rather than a function — every calendar composes it and
supplies its own names.

## On a core Date

```raku name="strftime"
use Date::Calendar::Strftime;

my $d = Date.new('2026-09-14') does Date::Calendar::Strftime;
say $d.strftime('%Y-%m-%d is day %j, ISO week %V of %G, weekday %u');
say $d.strftime('%F | %e | %-d | %05j | %%');
say $d.strftime('%A %d %B');
```

```output
2026-09-14 is day 257, ISO week 38 of 2026, weekday 1
2026-09-14 | 14 | 14 | 00257 | %
%A 14 %B
```

The codes are the C ones: `%F` for the ISO date, `%j` the day of the year,
`%V` and `%G` the ISO week and its year, `%u` Monday-is-1. The flags work
too — `%-d` strips the padding, `%05j` sets a width and a fill. Anything
the object cannot answer is left in the output as it was written, which is
what happened to `%A` and `%B` on the last line.

## The one thing to know

A core `Date` has no names. `%A` and `%B` need `day-name` and `month-name`
methods, which the `Date::Calendar::*` classes provide and `Date` does not —
so on a plain `Date` those two codes come out as themselves, silently. If you
want September spelled out on a core Date, `Date::Names` (which this
distribution already depends on) answers `mon(9)`, and the `%A` and `%B`
belong to the calendar classes.

The codes that do work on a core `Date` are the ones it can answer through
`.can` — and that is the mechanism this page tripped over. Under the Raku++
3.28.0 release, `.can('day-of-week')` on a `Date` with a role mixed in came
back empty, so `%u` and `%V` printed as literal `%u` and `%V` while
everything else was right. The engine has been fixed since, and the first
example now prints the same line under both.
