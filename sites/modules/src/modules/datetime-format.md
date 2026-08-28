---
name: DateTime::Format
version: 0.1.5
auth: zef:raku-community-modules
kind: Distribution · time
summary: strftime for Raku's DateTime — the % patterns everyone knows,
  with month and day names in six languages.
status: full
license: Artistic-2.0
suite: 3 files, green
tested: 2026-08-28
raku-land: https://raku.land/zef:raku-community-modules/DateTime::Format
source: https://github.com/raku-community-modules/DateTime-Format
---

## What it is for

Core `DateTime` prints ISO 8601 and nothing else. The moment a human is
going to read the timestamp — a log line, a report header, a filename —
you want `strftime`, the little pattern language that has outlived every
framework since C. This module is that, for Raku:

```raku name="strftime"
use DateTime::Format;

my $dt = DateTime.new('2026-08-28T14:30:00+02:00');
say strftime('%Y-%m-%d %H:%M', $dt);
say strftime('%A, %B %d', $dt);
say strftime('%a %d %b %Y %T %z', $dt);
```

```output
2026-08-28 14:30
Friday, August 28
Fri 28 Aug 2026 14:30:00 +0200
```

The patterns are the classic set: `%Y/%m/%d` for the date parts, `%H/%M/%S`
(and `%T` for all three), `%A/%a` for the weekday spelled out or
abbreviated, `%B/%b` the same for months, `%z` for the numeric offset,
`%s` for epoch seconds, `%%` for a literal percent. Anything the pattern
does not claim passes through untouched, so slashes, colons and words
just work.

## Month names in your language

The names behind `%A` and `%B` are pluggable, and the distribution ships
them for German, French, Dutch, Portuguese and Bulgarian alongside
English. Load a language module and select it:

```raku name="localized"
use DateTime::Format;
use DateTime::Format::Lang::FR;

set-datetime-format-lang('fr');
say strftime('%A %d %B %Y', DateTime.new('2026-08-28T00:00:00Z'));
```

```output
vendredi 28 août 2026
```

`set-datetime-format-lang` switches the default; `strftime`'s `:lang`
named argument does it per call. Your own language is
`add-datetime-format-month-names('xx', @names)` away — the lists are just
data.

## What about parsing?

Honesty requires a warning here: the module *declares* `strptime` — the
inverse, pattern-driven parsing — but in version 0.1.5 it is a stub, and
calling it dies with *Stub code executed* on any engine. The bundled
`DateTime::Format::RFC2822` class's `from-string` routes into the same
stub, so it cannot parse either. For parsing, stay with `DateTime.new`
on ISO strings or write a grammar; this page documents what runs, and
pattern-driven *parsing* is not yet part of that. Formatting — every
example above — is complete.

## Where the two engines differ

Nothing on this page. Every pattern shown, the language switching, and
even the `strptime` stub's failure mode behave identically under Raku++
and Rakudo.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install DateTime::Format`; it depends on nothing
   outside the core.
3. **Test** — the distribution's own suite: 3 files, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

Thirteen distributions depend on it. Note that the example outputs above
are stable because the input `DateTime` carries its own offset — format a
`DateTime.now` and your `%z` will be your machine's, which is the correct
kind of instability.
