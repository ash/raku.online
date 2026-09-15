---
name: Time::Duration::Parser
version: 0.0.3
auth: zef:raku-community-modules
kind: Distribution · time
summary: Turn a human-written duration — "2 hours", "1 week 2 days", "1:30" —
  into a number of seconds, with a month fixed at 30 days and a year at 365.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Time::Duration::Parser
source: https://github.com/raku-community-modules/Time-Duration-Parser.git
---

## What it is for

Configuration files and command-line flags want durations written the way
people say them: `30 minutes`, `2 weeks`, `1:30`. Turning that into a number
your `sleep` or your cache expiry can use is a small parsing job nobody enjoys
doing twice.

This distribution does it, and exposes the grammar as a class so you can
subclass or reuse it.

## Parsing a duration

```raku name="parse"
use Time::Duration::Parser;

for '30 seconds', '2 minutes', '1 hour', '3 days', '1 week',
    '1 week 2 days', '1 h 30 m' -> $s {
    say sprintf('%-14s -> %s seconds', "'$s'", duration-to-seconds($s));
}
```

```output
'30 seconds'   -> 30 seconds
'2 minutes'    -> 120 seconds
'1 hour'       -> 3600 seconds
'3 days'       -> 259200 seconds
'1 week'       -> 604800 seconds
'1 week 2 days' -> 777600 seconds
'1 h 30 m'     -> 5400 seconds
```

## Which unit names it knows

```raku name="units"
use Time::Duration::Parser;

my @units = <s sec secs second seconds m min mins minute minutes
             h hr hrs hour hours d day days w wk week weeks
             mo month months y yr year years>;

my (@ok, @no);
for @units -> $u {
    duration-to-seconds("2 $u").defined ?? @ok.push($u) !! @no.push($u);
}
say 'accepted : ', @ok.join(' ');
say 'rejected : ', @no.join(' ');
say '';
say 'a month is ', duration-to-seconds('1 month'), ' seconds — exactly 30 days';
say 'a year  is ', duration-to-seconds('1 year'),  ' seconds — exactly 365 days';
```

```output
accepted : s sec secs second seconds m min mins minute minutes h hr hrs hour hours d day days w week weeks mo month months y year years
rejected : wk yr

a month is 2592000 seconds — exactly 30 days
a year  is 31536000 seconds — exactly 365 days
```

`wk` and `yr` are rejected even though `hr`, `mo`, `sec` and `min` are
accepted, which looks like an oversight rather than a decision. A month is
exactly 30 days and a year exactly 365; there is no calendar arithmetic here,
so adding "one month" to a date is not what this computes.

## The clock form

```raku name="clock"
use Time::Duration::Parser;

for '1:30', '1:30:15', '0:01', '100:00', '1:70', '0:99:99' -> $s {
    my $v = duration-to-seconds($s);
    say sprintf('%-10s -> %s', "'$s'", $v.defined ?? $v.Int !! 'not parsed');
}
```

```output
'1:30'     -> 5400
'1:30:15'  -> 5415
'0:01'     -> 60
'100:00'   -> 360000
'1:70'     -> 7800
'0:99:99'  -> 6039
```

Note `1:70` and `0:99:99`: there is **no range check** on the clock form, so
nonsense minute and second fields are accepted and silently carried into the
total.

## The one thing to know

The space between the number and the unit is mandatory, and omitting it fails
silently to a value that numifies to zero.

```raku name="space-trap"
use Time::Duration::Parser;

for '1h', '1 h', '90m', '90 m', '1h30m', '1 h 30 m' -> $s {
    my $v = duration-to-seconds($s);
    say sprintf('%-10s -> %-8s defined=%s', "'$s'",
        $v.defined ?? $v.Int.Str !! 'undefined', $v.defined);
}
say '';
my $bad = duration-to-seconds('30m');
say 'duration-to-seconds("30m") is ', $bad.defined ?? 'defined' !! 'undefined';
say 'and + 0 turns it into ', ($bad // 0) + 0;
```

```output
'1h'       -> undefined defined=False
'1 h'      -> 3600     defined=True
'90m'      -> undefined defined=False
'90 m'     -> 5400     defined=True
'1h30m'    -> undefined defined=False
'1 h 30 m' -> 5400     defined=True

duration-to-seconds("30m") is undefined
and + 0 turns it into 0
```

Not an exception, not a `Failure`, not `-1` — an undefined value that `+ 0`
quietly turns into 0. `sleep duration-to-seconds('30m')` therefore sleeps for
no time at all and reports nothing. Every compact spelling a person would
actually type, and that `systemd`, Go and the cron-adjacent tools all accept,
is rejected invisibly.

Test `.defined` on the result before using it. There is no exception to catch.

## Where the two engines differ

Two places, both in the clock form's edges.

The clock form's **return type** differs: `duration-to-seconds('1:30')` is a
`Num` (`5400e0`) under Raku++ and an `Int` (`5400`) under Rakudo. Code doing
`=== 5400` or checking `.^name` will diverge. Coerce with `.Int` — as every
example above does — and the two agree.

Whitespace-only input also differs: `'  '` gives `0` under Raku++ and `Nil`
under Rakudo. The empty string gives `0` on both.

One thing that is not a divergence and is worth knowing: the grammar class is
usable directly. `Time::Duration::Parser.parse($s)` returns a `Match` or
`Nil`, which at least makes failure checkable without the `.defined` dance.
