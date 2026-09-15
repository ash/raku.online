---
name: Math::Curves
version: 0.0.1
auth: cpan:SAMGWISE
kind: Distribution · maths
summary: Two curve primitives for interpolation — a straight-line function and
  Bezier evaluation at a parameter for two, three or four control points.
status: divergent
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/?/Math::Curves
source: git://github.com/samgwise/p6-Math-Curves.git
---

## What it is for

Animation, easing and any kind of smooth interpolation all come down to
evaluating a curve at a parameter between 0 and 1. Bezier curves are the
standard choice because they are cheap, and because their control points are
an intuitive handle.

This distribution is the evaluation, for the two-, three- and four-point
cases and for an arbitrary list.

## Evaluating a curve

```raku name="bezier"
use Math::Curves;

say 'linear (two control points), from 0 to 10:';
for 0/1, 1/4, 1/2, 3/4, 1/1 -> $t {
    say sprintf('  t=%-5s -> %s', $t.raku, bézier($t, 0, 10).raku);
}
say '';
say 'quadratic (three), with the middle point pulled to 10:';
for 0/1, 1/4, 1/2, 3/4, 1/1 -> $t {
    say sprintf('  t=%-5s -> %s', $t.raku, bézier($t, 0, 10, 0).raku);
}
say '';
say 'cubic (four), the usual easing shape:';
for 0/1, 1/4, 1/2, 3/4, 1/1 -> $t {
    say sprintf('  t=%-5s -> %s', $t.raku, bézier($t, 0, 0, 10, 10).raku);
}
```

```output
linear (two control points), from 0 to 10:
  t=0.0   -> 0.0
  t=0.25  -> 2.5
  t=0.5   -> 5.0
  t=0.75  -> 7.5
  t=1.0   -> 10.0

quadratic (three), with the middle point pulled to 10:
  t=0.0   -> 0.0
  t=0.25  -> 3.75
  t=0.5   -> 5.0
  t=0.75  -> 3.75
  t=1.0   -> 0.0

cubic (four), the usual easing shape:
  t=0.0   -> 0.0
  t=0.25  -> 1.5625
  t=0.5   -> 5.0
  t=0.75  -> 8.4375
  t=1.0   -> 10.0
```

The cubic row is the classic ease-in-out: slow at both ends, fast through the
middle.

## The list form and the parameter range

```raku name="list"
use Math::Curves;

say 'a list of control points : ', bézier(1/2, (0, 10, 0)).raku;
say '';
say 't must be in 0..1 — the subset enforces it:';
for 0/1, 1/1, 3/2, -1/2 -> $t {
    my $r = try bézier($t, 0, 10);
    say sprintf('  t=%-6s -> %s', $t.raku, $r.defined ?? $r.Str !! 'refused');
}
```

```output
a list of control points : 5.0

t must be in 0..1 — the subset enforces it:
  t=0.0    -> 0
  t=1.0    -> 10
  t=1.5    -> refused
  t=-0.5   -> refused
```

Note the export is spelled with an acute accent — `bézier`, not `bezier` — and
there is **no ASCII alias**, so the accent must be typed everywhere.

## The one thing to know

`line($x, $gradient)` returns `$x + ($x * $gradient)`, not `$x * $gradient`.

```raku name="line-trap"
use Math::Curves;

for (2, 1/2), (10, 1/1), (4, 0/1), (5, 2/1) -> ($x, $g) {
    say sprintf('line(%2d, %-5s) = %-8s   x * g would be %s',
        $x, $g.raku, line($x, $g).raku, ($x * $g).raku);
}
say '';
say 'so a "gradient" of 0 is the identity rather than a flat line,';
say 'and the function never passes through the origin except at x = 0.';
```

```output
line( 2, 0.5  ) = 3.0        x * g would be 1.0
line(10, 1.0  ) = 20.0       x * g would be 10.0
line( 4, 0.0  ) = 4.0        x * g would be 0.0
line( 5, 2.0  ) = 15.0       x * g would be 10.0

so a "gradient" of 0 is the identity rather than a flat line,
and the function never passes through the origin except at x = 0.
```

The second parameter is a fractional **increment** applied to `x`, not a
slope. Anyone reading it as `y = mx` gets an answer wrong by exactly `x` —
which is a large error and a plausible-looking one.

## Where the two engines differ

On what happens when `t` is not a `Rat`, and it is a compile-time error
against a runtime one.

`bézier`'s `t` is declared `Transition`, a subset of `Rat`. So
`bézier(0, 0, 10)` and `bézier(1, 0, 10)` — the two **endpoints**, written the
obvious way with integer literals — do not dispatch. Rakudo reports it at
compile time and refuses the whole file; Raku++ compiles and fails at runtime
when that line is reached.

A program with such a call in a rarely taken branch therefore runs until it
gets there on one engine and will not compile at all on the other.

Write `0/1` and `1/1`, as every example on this page does. `Num` arguments
fail too — `0.5e0` does not match `Rat` — and `line`'s gradient is `Rat` as
well, so `line(2, 0.5e0)` fails where `line(2, 0.5)` succeeds.

The distribution declares no test files and no `auth` in its metadata.
