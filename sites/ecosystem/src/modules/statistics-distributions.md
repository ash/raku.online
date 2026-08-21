---
name: Statistics::Distributions
version: 0.1.8
auth: zef:antononcube
kind: Distribution · statistics
summary: Twenty-one named probability distributions, and one call that draws
  from any of them. Pure Raku, one dependency, no compiler and no C library.
status: full
license: Artistic-2.0
depends: Math::SpecialFunctions
suite: 4 files, green
tested: 2026-08-21
raku-land: https://raku.land/zef:antononcube/Statistics::Distributions
source: https://github.com/antononcube/Raku-Statistics-Distributions
---

## What it is for

You need numbers that look like something: heights that cluster around a mean,
response times with a long tail, a coin that lands heads three times in ten.
Writing that by hand means remembering the inverse of a distribution function.
This module remembers twenty-one of them for you, and hands them all to the
same call.

There are two things in it worth learning: `random-variate`, which draws from a
distribution, and `quantile`, which reads percentiles off data you already
have. Everything else is the catalogue of distributions those two work with.

```raku name="catalogue"
use Statistics::Distributions;

say known-distributions.keys.elems;
say known-distributions.keys.grep(*.starts-with('normal')).sort;
say random-variate('Normal', 3).elems;
```

```output
132
(normal normal-distribution normal_distribution normaldistribution)
3
```

Twenty-one distributions under a hundred and thirty-two names: every one
answers to `Normal`, `NormalDistribution`, `Normal-Distribution` and
`Normal_Distribution`, in any case. Spelling is not the thing this module wants
you to get right.

## Your first draw

`random-variate($distribution, $n)` gives you `$n` numbers. Ask for one and you
get a bare number, not a one-element list.

```raku sample name="first-draw"
use Statistics::Distributions;

my @heights = random-variate(NormalDistribution.new(:mean(170), :sd(8)), 5);
say .fmt('%.1f') for @heights;
```

```output
170.6
164.3
164.0
183.4
176.4
```

Those five numbers will be different for you, and different again on the next
run — that is the point of the module. What does not change is the shape of the
answer, and where the numbers land:

```raku name="draw-shape"
use Statistics::Distributions;

my @s = random-variate(NormalDistribution.new(:mean(170), :sd(8)), 1000);

say @s.elems;                      # how many you asked for
say @s.head.WHAT;                  # what each one is
say 168 < @s.sum / @s.elems < 172; # the mean lands where you set it
```

```output
1000
(Num)
True
```

Every distribution is also a class you can hold on to, which is what you want
when the same distribution is drawn from in several places:

```raku sample name="reuse-a-distribution"
use Statistics::Distributions;

my $noise = NormalDistribution.new(:mean(0), :sd(0.5));

say ($_ + random-variate($noise)).fmt('%.2f') for 1, 2, 3;
```

```output
1.29
1.71
3.42
```

## Naming the parameters

Each distribution takes the parameters its textbook definition takes, and
answers to both the spelled-out name and the Greek letter. `.Hash` is how you
ask an object what it ended up with — and the way to print one, since a bare
`say $distribution` renders its parameters in hash order, which is not stable
under Rakudo.

```raku name="parameters"
use Statistics::Distributions;

say NormalDistribution.new(:mean(170), :sd(8)).Hash;
say NormalDistribution.new(:µ(170), :σ(8)).Hash;
say NormalDistribution.new(170, 8).Hash;
```

```output
{class => Normal, mean => 170, sd => 8}
{class => Normal, mean => 170, sd => 8}
{class => Normal, mean => 170, sd => 8}
```

The three lines are the same distribution, written three ways. The Greek forms
are not decoration: `ChiSquareDistribution` takes `:ν`, the stable distributions
take `:μ`, `:σ` and `:ξ`, and `WeibullDistribution` takes `:a` and `:b` as
aliases for its shape and scale. All of them work under both engines — the
Unicode named-argument path is one of the things this distribution's own test
suite taught Raku++.

| Distribution | Parameters | Greek |
|---|---|---|
| `NormalDistribution` | `:mean`, `:sd` | `:µ`, `:σ` |
| `UniformDistribution` | `:min`, `:max` | — |
| `ExponentialDistribution` | `:lambda` | — |
| `GammaDistribution` | `:a` (shape), `:b` (scale) | — |
| `ChiSquareDistribution` | `:nu` | `:ν` |
| `StudentTDistribution` | `:nu`, `:mean`, `:sd` | `:ν`, `:µ`, `:σ` |
| `WeibullDistribution` | `:shape`, `:scale`, `:location` | `:a`, `:b`, `:μ` |
| `RayleighDistribution` | `:sigma` | `:σ` |
| `BernoulliDistribution` | `:p` | — |
| `BinomialDistribution` | `:n`, `:p` | — |
| `DiscreteUniformDistribution` | `:min`, `:max` | — |
| `BenfordDistribution` | `:b` (digit base) | — |

## Discrete draws

Four of the distributions hand back whole numbers rather than reals. A die is a
discrete uniform:

```raku name="dice"
use Statistics::Distributions;

my @rolls = random-variate(DiscreteUniformDistribution.new(1, 6), 6000);
say @rolls.unique.sort;
say so @rolls.all ~~ Int;

my %seen = @rolls.Bag;
say so %seen.values.all ~~ 800..1200;
```

```output
(1 2 3 4 5 6)
True
True
```

A biased coin is a Bernoulli, and it gives you 1 and 0 rather than True and
False, so you can add them up:

```raku name="biased-coin"
use Statistics::Distributions;

# A coin that comes up heads 30% of the time, thrown 10,000 times.
my @throws = random-variate(BernoulliDistribution.new(0.3), 10_000);
my $heads  = @throws.grep(1).elems;

say @throws.unique.sort;                 # only ever 0 or 1
say 0.28 < $heads / @throws.elems < 0.32;
```

```output
(0 1)
True
```

## Uniform, and the range it draws from

`UniformDistribution` is the one people reach for first, and it is a thin cover
over Raku's own `(min .. max).rand`:

```raku name="uniform"
use Statistics::Distributions;

my @u = random-variate(UniformDistribution.new(-1, 1), 500);
say @u.elems;
say so @u.all ~~ -1 .. 1;
say -0.2 < @u.sum / @u.elems < 0.2;
```

```output
500
True
True
```

> On Raku++ **3.5.1 and earlier this returns a column of zeros**, because
> `Range.rand` answered 0 for every range. The module's own test suite did not
> catch it — it checks how many numbers came back and what type they are, not
> what they are — and neither will yours. If `random-variate(UniformDistribution.new(5, 6), 5)`
> gives you five zeros, that is the engine, and the fix is to upgrade.

## Reading quantiles off data you already have

`quantile` is the half of this module that has nothing to do with random
numbers. Hand it measurements and it gives you the cut points:

```raku name="quantiles"
use Statistics::Distributions;

my @data = 1 .. 100;

say quantile(@data);                        # the quartiles, by default
say quantile(@data, [0.05, 0.5, 0.95]);
say quantile(@data, :pairs);
```

```output
[26 51 76]
[6 51 96]
[0.25 => 26 0.5 => 51 0.75 => 76]
```

`:pairs` keeps each probability next to its value, which is what you want when
the list is going somewhere other than the next line of code. The optional
third argument selects the interpolation scheme, as a pair of pairs — the
default is `[[0, 0], [1, 0]]`, the one R calls type 1.

## Mixtures and products

Two distributions are built from others rather than from parameters. A
**mixture** draws from one of several distributions, choosing by weight — the
shape you want when your data has two populations in it:

```raku name="mixture"
use Statistics::Distributions;

# 30% of the readings come from one process, 70% from another.
my $mix = MixtureDistribution.new(
    [0.3, 0.7],
    [NormalDistribution.new(0, 1), NormalDistribution.new(10, 1)],
);

my @m = random-variate($mix, 2000);
say @m.elems;
say 0.26 < @m.grep(* < 5).elems / @m.elems < 0.34;
```

```output
2000
True
```

A **product** draws from all of them at once, giving you one tuple per draw:

```raku name="product"
use Statistics::Distributions;

# One draw = one (x, y) pair, x normal and y exponential, independent.
my $pair = ProductDistribution.new(
    NormalDistribution.new(0, 1),
    ExponentialDistribution.new(1),
);

my @pairs = random-variate($pair, 4);
say @pairs.elems;
say @pairs[0].elems;
say so @pairs.map(*.[1]).all >= 0;     # the exponential half is never negative
```

```output
4
2
True
```

## A worked example: a day of response times

Response times are the standard case for a long-tailed distribution: most
requests are fast, a few are not, and the mean tells you almost nothing. A
gamma with shape 2 makes a realistic-looking day, and `quantile` reads the
percentiles you would actually put on a dashboard.

```raku sample name="response-times"
use Statistics::Distributions;

# A day of response times: mostly fast, with a long tail.
my @ms = random-variate(GammaDistribution.new(2, 40), 5000);
my ($p50, $p95, $p99) = quantile(@ms, [0.5, 0.95, 0.99]);

say "p50  {$p50.fmt('%6.1f')} ms";
say "p95  {$p95.fmt('%6.1f')} ms";
say "p99  {$p99.fmt('%6.1f')} ms";
```

```output
p50    68.2 ms
p95   192.0 ms
p99   268.6 ms
```

The numbers move every run; the relationships do not, and those are what a test
around code like this should assert:

```raku name="response-time-assertions"
use Statistics::Distributions;

my @ms = random-variate(GammaDistribution.new(2, 40), 5000);
my ($p50, $p95, $p99) = quantile(@ms, [0.5, 0.95, 0.99]);

say $p50 < $p95 < $p99;          # quantiles come out in order
say @ms.min >= 0;                # a gamma variate is never negative
say 50 < $p50 < 120;             # the median sits near shape × scale
```

```output
True
True
True
```

## Where the two engines differ

Everything above runs identically under Raku++ and under Rakudo. Three things
around the edges do not, and all three bite when you try to pin a random
program down.

**`srand` pins the sequence under Raku++, and does not under Rakudo.** Seeding
and re-seeding gives you the same draws again here; under Rakudo 2026.06 it does
not, so a seed is not a way to make a run reproducible across both engines.

```raku sample name="srand"
use Statistics::Distributions;

srand(42);
my @a = random-variate(NormalDistribution.new(0, 1), 3);
srand(42);
my @b = random-variate(NormalDistribution.new(0, 1), 3);

say @a eqv @b;
```

| | Raku++ | Rakudo 2026.06 |
|---|---|---|
| `srand(42)` twice, same draws | `True` | `False` |

**`say $distribution` is not stable under Rakudo.** A distribution's `gist` is
built by walking its parameter hash, and Rakudo randomises hash order per
process, so the same object prints `Normal(:mean(3), :sd(1))` in one run and
`Normal(:sd(1), :mean(3))` in the next. Print `.Hash` instead — `say` sorts a
hash's keys, so it is the same line every time on both engines.

**`.round(0.1)` answers a Num under Raku++ and a Rat under Rakudo**, so a
rounded variate can print as `178.10000000000002` here and `178.1` there. Use
`.fmt('%.1f')` for anything you are going to show or compare; the two engines
format identically.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install Statistics::Distributions`, which resolves
   against the same ecosystem index zef reads, fetches from the same CDN, and
   writes the same `~/.raku` store. The one dependency,
   `Math::SpecialFunctions`, comes with it.
3. **Test** — the distribution's own test suite, 4 files, run by Raku++ before
   the install is marked good. Green.
4. **Run** — every example on this page, twice under each engine, as this site
   is built. A page whose output has moved does not ship.

Getting there took five engine fixes that this distribution's suite found first
— `.^method_names`, multi-method candidates across the inheritance chain,
Unicode named arguments, `:a(:$!attr)` aliases and `.flat(:hammer)` — and one
more that its suite did not: `Range.rand`, which is why `UniformDistribution`
is called out above.
