---
name: DateTime::Format::LikeGo
version: 0.0.2
auth: none stated
kind: Distribution · time
summary: Write a datetime layout the way Go does — by spelling out a reference
  instant rather than using percent codes — and render a DateTime with it.
status: full
suite: 1 file, green
tested: 2026-09-15
license: MIT
depends: DateTime::Format
raku-land: https://raku.land/?/DateTime::Format::LikeGo
source: git://github.com/avuserow/perl6-datetime-format-likego.git
---

## What it is for

Nobody remembers whether `%d` is the day or the day of the year. Go's answer
was to drop the codes entirely: you write out a specific reference instant in
the layout you want, and the library matches the pieces. `2006-01-02` means
year-month-day because those are that instant's year, month and day.

This distribution brings that idea to Raku, rewriting a Go layout into an
strftime format and handing it to `DateTime::Format`.

## Formatting

```raku name="format"
use DateTime::Format::LikeGo;

my $dt = DateTime.new(2025, 3, 9, 15, 4, 5, :timezone(0));

for '2006-01-02',
    '2006-01-02 15:04:05',
    '01/02/06',
    '15:04',
    '02 Jan 2006',
    '_2 January 2006' -> $fmt {
    say sprintf('%-22s -> %s', $fmt, go-date-format($fmt, $dt));
}
```

```output
2006-01-02             -> 2025-03-09
2006-01-02 15:04:05    -> 2025-03-09 15:04:05
01/02/06               -> 03/09/25
15:04                  -> 15:04
02 Jan 2006            -> 09 Mar 2025
_2 January 2006        ->  9 March 2025
```

The reference instant is 15:04:05 on 2 January 2006, which in American order
is 1/2 3:04:05 PM '06 — the digits 1 through 7 in sequence. That mnemonic is
the whole trick.

## The tokens it knows

```raku name="tokens"
use DateTime::Format::LikeGo;

my $dt = DateTime.new(2025, 3, 9, 15, 4, 5, :timezone(0));

say 'the recognised tokens are exactly:';
say '  Mon Monday Jan January 02 _2 01 15 03 _3 04 pm PM 05 06 2006 MST';
say '';
for 'Mon', 'Monday', 'Jan', 'January', '2006', '06', '01', '02', '15', '04', '05' -> $t {
    say sprintf('  %-10s -> %s', $t, go-date-format($t, $dt));
}
```

```output
the recognised tokens are exactly:
  Mon Monday Jan January 02 _2 01 15 03 _3 04 pm PM 05 06 2006 MST

  Mon        -> Sun
  Monday     -> Sunday
  Jan        -> Mar
  January    -> March
  2006       -> 2025
  06         -> 25
  01         -> 03
  02         -> 09
  15         -> 15
  04         -> 04
  05         -> 05
```

`MST` maps to a numeric offset rather than a zone abbreviation, so a layout
using it will not produce the three-letter name Go would.

## The one thing to know

The one Go layout every Go programmer knows by heart is rejected.

```raku name="reference-trap"
use DateTime::Format::LikeGo;

my $dt = DateTime.new(2025, 3, 9, 15, 4, 5, :timezone(0));

for 'Mon Jan 2 15:04:05 2006',
    'Monday, January 2, 2006',
    '3:04PM',
    'Jan 2, 2006',
    '1/2/2006',
    '2006-01-02T15:04:05Z07:00',
    '15:04:05.000' -> $fmt {
    my $r = try go-date-format($fmt, $dt);
    say sprintf('%-30s -> %s', $fmt, $! ?? 'refused' !! $r);
}
```

```output
Mon Jan 2 15:04:05 2006        -> refused
Monday, January 2, 2006        -> refused
3:04PM                         -> refused
Jan 2, 2006                    -> refused
1/2/2006                       -> refused
2006-01-02T15:04:05Z07:00      -> refused
15:04:05.000                   -> refused
```

Go's canonical reference is `Mon Jan 2 15:04:05 MST 2006`, and this module has
no mapping for the non-padded `2`. It understands only the zero-padded
variants — `02` not `2`, `01` not `1`, `03` or `_3` not `3`. Copy the layout
out of Go's own documentation and you get a fatal error whose message blames a
"typo".

There is a second, subtler face of the same design. The substitution needs a
word boundary on **both** sides of a token, so tokens jammed together without
a separator are silently skipped: `15:04:05` works because the colons separate
them, and `3:04PM` leaves `04PM` untouched because they form one word.

And any **literal digit** left in the layout is fatal, so you cannot write
`Q1 2006` or put a year in prose.

Pad everything, separate everything, and keep digits out of the literal text.

## Where the two engines differ

Only in one place, and only for a call nobody should make. The helper
`go-to-strftime`, which does the layout rewriting, is an `our sub` that is
**not exported**. Calling it unqualified resolves on Raku++ and is a
compile-time undeclared routine on Rakudo. Fully qualified it works on both.

Everything about the exported `go-date-format` — every layout, every
rejection, every rendered string — was identical on the two engines.

The distribution declares no `auth`, so it has no canonical raku.land path.
