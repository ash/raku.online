---
name: Math::Random
version: 0.1.3
auth: zef:raku-community-modules
kind: Distribution · maths
summary: Seedable pseudo-random generators as objects — a Mersenne Twister
  matching the reference implementation, and a linear congruential one with
  Java's constants.
status: divergent
suite: 1 file, green
tested: 2026-09-15
raku-land: https://raku.land/zef:raku-community-modules/Math::Random
source: https://github.com/raku-community-modules/Math-Random
---

## What it is for

Raku's `rand` is a good generator and a bad one to test against: there is
one of it, shared by the whole program, and you cannot seed it. A
simulation that has to be reproducible, or a test that has to produce the
same "random" data on every run, needs a generator it owns and can set the
seed of.

This distribution is two of them as objects, with a Java-flavoured method
set. The Mersenne Twister is the one to use.

## A reproducible stream

```raku name="mersenne"
use Math::Random::MT;

my $m = Math::Random::MT.mt19937;
$m.setSeed(5489);
say (^6).map({ $m.nextInt }).join(', ');

$m.setSeed(5489);
say (^6).map({ $m.nextInt }).join(', ');

my $n = Math::Random::MT.mt19937_64;
$n.setSeed(5489);
say (^3).map({ $n.nextInt }).join(', ');

my $b = Math::Random::MT.mt19937;
$b.setSeed(12345);
my @bits = (^2000).map({ $b.nextBoolean });
say 'true: ', +@bits.grep(*.so), '  false: ', +@bits.grep(!*.so);
say (^8).map({ $b.nxt(4) }).all < 16;
```

```output
3499211612, 581869302, 3890346734, 3586334585, 545404204, 4161255391
3499211612, 581869302, 3890346734, 3586334585, 545404204, 4161255391
3379370268, 1075804871, 3052309686
true: 989  false: 1011
all(True, True, True, True, True, True, True, True)
```

Those first six numbers are the canonical MT19937 output for seed 5489, so
the implementation is faithful and a stream recorded from it can be
replayed anywhere. Re-seeding rewinds it exactly. `mt19937` and
`mt19937_64` are the two presets; `.new` on its own does not give a usable
generator, so always go through one of them and then `setSeed`.

## The one thing to know

The other generator, `Math::Random::JavaStyle`, is broken in four separate
ways and should not be used. Its `nextBoolean` is always `True`:

```raku name="javastyle"
use Math::Random::JavaStyle;

my $j = Math::Random::JavaStyle.bless;
$j.setSeed(12345);
my @bits = (^2000).map({ $j.nextBoolean });
say 'true: ', +@bits.grep(*.so), '  false: ', +@bits.grep(!*.so);

my $k = Math::Random::JavaStyle.bless;
$k.setSeed(7);
say 'nxt(1) draws: ', (^6).map({ $k.nxt(1) }).join(', ');
say 'should all be 0 or 1';

say (try Math::Random::JavaStyle.new(42)) // 'new(42): refused';
```

```output
true: 2000  false: 0
nxt(1) draws: 131073, 131073, 131073, 131072, 131072, 131072
should all be 0 or 1
new(42): refused
```

Two thousand draws, every one true. The cause is in `nxt`, which adds a
constant that only cancels for widths of sixteen bits or more — so every
narrow draw comes back offset by a large power of two, and a boolean test
on the whole number is therefore always true. `nextInt`, which is a
thirty-two bit draw, is fine.

The constructor is broken too: `new` calls itself and fails on arity, so
the only way to build one is `.bless` followed by `setSeed`, as above.
`nextDouble` and `nextGaussian` throw on every call on both generators,
because they return an integer from a method declared to return a `Num`.

## Where the two engines differ

Nothing here differs between the engines — the Mersenne Twister produces
identical streams and the Java-style generator is identically broken on
both. The badge is amber because of that second class, not because of an
interpreter disagreement.

If you want a seedable generator, use `Math::Random::MT` and stay away from
the other one. If you want a normal distribution, neither `nextGaussian`
works; compute Box–Muller from two `nextInt` draws yourself.
