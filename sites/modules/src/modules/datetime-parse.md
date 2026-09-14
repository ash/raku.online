---
name: DateTime::Parse
version: 0.9.3
auth: github:sergot
kind: Distribution · time
summary: A DateTime from the date strings the web writes — RFC 1123, the
  older RFC 850, C's `asctime`, and ISO 8601 — through one constructor that
  tries the grammars in turn.
status: full
suite: 3 files, green
tested: 2026-09-14
raku-land: https://raku.land/github:sergot/DateTime::Parse
source: https://github.com/sergot/datetime-parse
---

## What it is for

`DateTime.new('2026-09-14T15:04:05Z')` works because that is the one
format the core understands. An HTTP `Date` header says `Sun, 06 Nov 1994
08:49:37 GMT`, a cookie's `expires` may still say `Sunday, 06-Nov-94
08:49:37 GMT`, and a log line from a C program says `Sun Nov  6 08:49:37
1994` — the three forms RFC 7231 tells a client it must accept. This
distribution is a grammar for each with actions that build a `DateTime`,
and a constructor that tries them. It is what `HTTP::UserAgent` and its
relatives use to read a server's headers; five distributions depend on it.

## The four forms

```raku name="parse"
use DateTime::Parse;

say DateTime::Parse.new('Sun, 06 Nov 1994 08:49:37 GMT');
say DateTime::Parse.new('Sun Nov  6 08:49:37 1994');
say DateTime::Parse.new('2026-09-14T15:04:05Z');
say DateTime::Parse.new('Sun, 06 Nov 1994 08:49:37 GMT').^name;
say DateTime::Parse.new('Sunday, 06-Nov-94 08:49:37 GMT').year;
say (try { DateTime::Parse.new('2026-09-14 15:04:05') }) // $!.^name;
```

```output
1994-11-06T08:49:37Z
1994-11-06T08:49:37Z
2026-09-14T15:04:05Z
DateTime
94
X::DateTime::CannotParse
```

What comes back is a plain core `DateTime` — the class is named after the
parser, but `new` returns the parsed value rather than an instance of
itself, so nothing downstream has to know where the object came from. A
string none
of the grammars accept throws `X::DateTime::CannotParse` with the text in
the message. The `:timezone` option applies an offset in seconds for a
format that carries none, and `:rule` names one grammar to try instead of
all of them.

## The one thing to know

The two-digit year is taken literally. RFC 850's `06-Nov-94` is the year
**94**, not 1994 — the fifth line above — because the grammar reads the
digits into the year field and nothing adds the century. The format was
obsolete before the module was written and still turns up in cookies from
old servers, so if you read cookie expiry dates, check `.year < 100` and
add 1900 or 2000 by RFC 6265's rule (69 and up is the twentieth century)
before trusting the result. Nothing else in the module has this problem;
the other three forms carry four digits.

The space-separated ISO form, `2026-09-14 15:04:05`, is not one of the
four: only the `T` spelling is accepted, so a timestamp from a database
export needs its space turned into a `T` first.
