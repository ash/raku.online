---
name: EuclideanRhythm
version: 0.0.6
auth: zef:jonathanstowe
kind: Distribution · music
summary: Spread a number of hits as evenly as the integers allow over a number
  of slots, using Bjorklund's construction, and hand the bar back as booleans.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:jonathanstowe/EuclideanRhythm
source: git://github.com/jonathanstowe/EuclideanRhythm.git
---

## What it is for

Put five hits in sixteen slots as evenly as you can and you get the Bossa Nova
clave. Put three in eight and you get the tresillo. Godfried Toussaint's
observation was that a surprising number of the world's traditional rhythms
are exactly this — the most even distribution the integers permit — and that
Bjorklund's algorithm from particle-accelerator timing generates all of them.

This distribution is that algorithm, for anyone writing a sequencer, a drum
machine or a generative piece.

## Generating a bar

```raku name="rhythm"
use EuclideanRhythm;

sub pattern($e) { $e.once.map({ $_ ?? 'x' !! '.' }).join }

for (16, 7), (8, 3), (16, 5), (13, 5), (12, 4), (8, 8), (8, 0), (5, 1) -> ($s, $f) {
    my $e = EuclideanRhythm.new(slots => $s, fills => $f);
    say sprintf('%2d slots %2d fills  %-16s  (length %d, %d hits)',
        $s, $f, pattern($e), $e.once.elems, $e.once.grep(?*).elems);
}
```

```output
16 slots  7 fills  x..x.x.x..x.x.x.  (length 16, 7 hits)
 8 slots  3 fills  x..x..x.          (length 8, 3 hits)
16 slots  5 fills  .x..x..x..x..x..  (length 16, 5 hits)
13 slots  5 fills  .x.x..x.x..x.     (length 13, 5 hits)
12 slots  4 fills  x..x..x..x..      (length 12, 4 hits)
 8 slots  8 fills  xxxxxxxx          (length 8, 8 hits)
 8 slots  0 fills  ........          (length 8, 0 hits)
 5 slots  1 fills  x....             (length 5, 1 hits)
```

`8/3` is the tresillo. `16/5` is the Bossa Nova — and note it **starts on a
rest**: the construction gives you the most even distribution, not one
guaranteed to land on the downbeat. Rotate it yourself if you want the accent
at the front.

## The repeating form

```raku name="list"
use EuclideanRhythm;

my $e = EuclideanRhythm.new(slots => 8, fills => 3);

say 'once  : ', $e.once.map({ $_ ?? 'x' !! '.' }).join, '   (', $e.once.elems, ' slots)';
say 'list  : ', $e.list[^24].map({ $_ ?? 'x' !! '.' }).join, '   (first 24 of an endless Seq)';
say '';
say 'slots : ', $e.slots, '   fills : ', $e.fills;
```

```output
once  : x..x..x.   (8 slots)
list  : x..x..x.x..x..x.x..x..x.   (first 24 of an endless Seq)

slots : 8   fills : 3
```

`once` gives you one bar. `list` gives you that bar repeated **without end**,
which is convenient for driving a loop and is the thing to be careful with.

## The one thing to know

`.list` never terminates, and the obvious guard does not tell you so.

Asking `.elems` on it hangs forever under Rakudo. Under Raku++ it silently
returns 1048576 — two to the twentieth, a truncation rather than an answer.
And `.is-lazy`, which is what you would reach for to detect the endless case,
reports `True` on Raku++ and `False` on Rakudo, so it cannot be used to tell
them apart portably.

Always bound it, as the example above does with `[^24]`, or use `once` and
repeat it yourself.

## The constructor

```raku name="constructor"
use EuclideanRhythm;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-28s %s', $label, $! ?? 'refused' !! 'accepted');
}

attempt 'fills > slots',   { EuclideanRhythm.new(slots => 4, fills => 9) };
attempt 'fills == slots',  { EuclideanRhythm.new(slots => 4, fills => 4) };
attempt 'fills == 0',      { EuclideanRhythm.new(slots => 4, fills => 0) };
attempt 'an unknown named argument', { EuclideanRhythm.new(slots => 4, fills => 2, wibble => 1) };
```

```output
fills > slots                refused
fills == slots               accepted
fills == 0                   accepted
an unknown named argument    accepted
```

`fills > slots` is refused by a `where` constraint, which is the right check
in the right place. Everything else is accepted — including named arguments
the class has never heard of.

Which matters, because the constructor accepts a `rotate` argument and does
**nothing whatever** with it. There is no `$!rotate` attribute; the parameter
is declared, defaulted and discarded. Anyone who finds it in the source and
expects a rotated bar gets a byte-identical pattern and no complaint.

## Where the two engines differ

Twice, both on mistakes.

Omitting `fills` entirely gives `X::Attribute::Required` on Raku++ and
`X::Numeric::Uninitialized` on Rakudo, because Rakudo runs the constructor's
arithmetic before the required-attribute check fires. Both refuse it; the
message points at different things.

And `.list`, as above: a hang on one engine, a silently truncated count on the
other. That is the one to plan around, because a bounded slice works
identically on both and an unbounded one works on neither.
