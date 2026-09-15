---
name: Game::Stats
version: 0.2.11
auth: cpan:HOLYGHOST
kind: Distribution · statistics
summary: Descriptive statistics and discrete probability as five small
  classes — an append-only sample, its mean and variance, covariance and
  correlation, and a Bayes helper.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: GPL-3.0
raku-land: https://raku.land/CPAN:HOLYGHOST/Game::Stats
source: http://cpan.metacpan.org/authors/id/H/HO/HOLYGHOST/Perl6/
---

## What it is for

The first statistics any simulation needs: collect numbers, then ask for
their total, their mean and their spread; given two such collections, ask
whether they move together. The distribution adds a discrete-probability
class on top, with the conjunction, disjunction, conditional and Bayes
operations over an indexed probability vector.

Despite the name there is nothing game-specific in it — no dice, no random
number generator, no sampling. It is a small statistics library.

## Samples and their moments

```raku name="samples"
use Game::Stats::Population;
use Game::Stats::DistributionPopulation;

my $p = Game::Stats::Population.new;
$p.add($_) for 3, 1, 4, 1, 5;
say $p.population.join(',');
say $p.nth(0), ' ', $p.nth(4);

my $d = Game::Stats::DistributionPopulation.new;
$d.add($_) for 0.1, 0.2, 0.3, 0.4;
say 'sum       ', $d.GeneratedNumber;
say 'mean      ', $d.Expectance;
say 'variance  ', $d.Variance;
say 'cumulative to index 2: ', $d.Cumulative(2);
```

```output
3,1,4,1,5
3 5
sum       1
mean      0.25
variance  0.016667
cumulative to index 2: 0.3
```

`Population` is the append-only container and
`DistributionPopulation` the subclass that computes over it.
`GeneratedNumber` is the sum, `Expectance` the mean, and `Cumulative` a
running total up to an index — which is what you index into when turning a
uniform draw into a categorical one.

The probability class works over a vector of probabilities by index:

```raku name="probability"
use Game::Stats::Probablity;

my $P = Game::Stats::Probability.new(xpop => [0.2, 0.3, 0.5]);
say (^3).map({ $P.P($_) }).join(' ');
say 'and      ', $P.Pand(0, 0.5);
say 'or       ', $P.Por(0, 1, 0.5);
say 'cond     ', $P.CondP(0, 0.5);
say 'bayes    ', $P.Bayes([0, 1, 2], [0.9, 0.5, 0.1], 0);
```

```output
0.2 0.3 0.5
and      0.1
or       0.4
cond     0.5
bayes    0.473684
```

## The one thing to know

The distribution is named `Game::Stats` and there is no `Game::Stats` unit
to load, so `use Game::Stats;` fails. Each of the five units must be loaded
by its own name — and the probability one is **misspelled in the file name
while the class inside it is not**:

```raku name="spelling"
say (try { EVAL 'use Game::Stats; 1' }) // 'use Game::Stats: not a unit';
say (try { EVAL 'use Game::Stats::Probablity; 1' }) // 'as shipped: no';
say (try { EVAL 'use Game::Stats::Probability; 1' }) // 'spelled right: no';
say (try { EVAL 'use Game::Stats::Probablity; Game::Stats::Probability.^name' })
    // 'the class: no';
```

```output
use Game::Stats: not a unit
1
spelled right: no
Game::Stats::Probability
```

So you write `use Game::Stats::Probablity;` — no second *i* — and then
refer to `Game::Stats::Probability` with it. The two spellings are never
the same one at the same time.

## Where the two engines differ

Nothing here differs between the engines: both produce the same numbers,
including the wrong ones. The badge on this page is amber for a different
reason, which is that some of those numbers are wrong on both.

`Covariance` flattens its two populations into a single list and then walks
that list in pairs, so for x = 1,2,3 and y = 4,5,6 it pairs (1,2), (3,4)
and (5,6) instead of (1,4), (2,5) and (3,6). The result is −0.667 where the
textbook answer is +0.667 — wrong sign and wrong value. `Correlation` is
built on it and inherits the fault: correlating a variable with itself,
which is 1 by definition, gives 0.333.

`Variance` divides by *n*−1 while `Expectance` divides by *n*, so the two
conventions are mixed even before that. And a division by zero yields a
rational with a zero denominator rather than an error, which then throws
when you print it.

The sample container, the mean, the cumulative totals and the probability
class are all sound. Treat the covariance and correlation pair as unusable
and compute those two yourself.
