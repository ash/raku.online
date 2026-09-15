---
name: P5localtime
version: 0.0.11
auth: zef:lizmat
kind: Distribution · time
summary: Perl's `localtime` and `gmtime` — an epoch second broken into
  calendar fields, or formatted as the fixed-width C timestamp — for code
  being carried across from Perl.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:lizmat/P5localtime
source: https://github.com/lizmat/P5localtime
---

## What it is for

Raku has `DateTime`, which is better than what Perl offered in every way
that matters. That is no help when you are moving a working Perl program
across a line at a time and want each step to keep passing its tests. This
distribution is part of a family that supplies Perl's builtins under their
own names with their own semantics, so the port can proceed without
rewriting the date handling first and the rewrite can come later.

It gives the two decomposition builtins. `gmtime` breaks an epoch second
into calendar fields in UTC, `localtime` in the process's own timezone, and
either will format the fields as the fixed-width string C's `asctime`
produces.

## Fields, or a string

```raku name="decompose"
use P5localtime;

my @g = gmtime(1_000_000_000);
say @g.elems;
say @g[0..8].join(' ');

my ($sec, $min, $hour, $mday, $mon, $year) = @g;
say "{$year + 1900}-{$mon + 1}-$mday {$hour}:{$min}:{$sec}";

say gmtime(Scalar, 1_000_000_000);
say gmtime(Scalar, 0);
say gmtime(0)[9], ' ', gmtime(0)[10];
```

```output
11
40 46 1 9 8 101 0 251 0
2001-9-9 1:46:40
Sun Sep  9 01:46:40 2001
Thu Jan  1 00:00:00 1970
0 UTC
```

The list is Perl's nine fields with two Raku additions on the end: the UTC
offset in seconds and the zone abbreviation. Passing the `Scalar` type
object as the first argument selects the string form instead — that is the
module's spelling of Perl's list-versus-scalar context, and it has to be
the literal type object, not an anonymous `$`.

The two traps Perl programmers already know are intact, deliberately.
`mon` is zero-based, so September is 8, and `year` counts from 1900, so
2001 is 101. The example adds them back.

## The one thing to know

`localtime` reads the timezone once, when the process starts, and nothing
you do afterwards moves it:

```raku name="timezone"
use P5localtime;

my $before = localtime(Scalar, 0);
%*ENV<TZ> = 'UTC';
my $after = localtime(Scalar, 0);
say $before eq $after;
say gmtime(Scalar, 0);
say gmtime(0)[9];
```

```output
True
Thu Jan  1 00:00:00 1970
0
```

Assigning to the environment variable at run time has no effect, because
the zone was resolved before your first line ran. The only way to steer
`localtime` is to set `TZ` in the environment *before* launching the
program. That also means any example, test or golden file built on
`localtime` is pinned to whichever machine produced it — which is why
everything printed above uses `gmtime`, the half of the pair that answers
the same thing everywhere.

Calling either with no epoch argument at all uses the current time, which
is never what a test wants.
