---
name: Algorithm::Genetic
version: 0.0.2
auth: github:samgwise
kind: Distribution · algorithms
summary: A skeleton for a genetic search you fill in — where the population is
  not sorted when `evolve` returns, so `.tail` is usually not the best.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:samgwise/Algorithm::Genetic
source: git://github.com/samgwise/p6-algorithm-genetic.git
---

## What it is for

A genetic algorithm is four decisions — how a candidate is represented, how it
is scored, how two are crossed, how one is mutated — plus a lot of scaffolding
around them. This distribution is the scaffolding: five roles you compose,
supplying only the four decisions.

## Composing it

```raku name="basics"
use Algorithm::Genetic;
use Algorithm::Genetic::Genotype;   # for the `is mutable` trait

class Eq does Algorithm::Genetic::Genotype {
    has Int $.a is rw is mutable({ (^20).pick });
    has Int $.b is rw is mutable({ (^20).pick });
    method !calc-score { -(($!a + $!b - 17).abs) }
    method new-random { self.new(a => (^20).pick, b => (^20).pick) }
}

class Search does Algorithm::Genetic {
    method is-finished { self.population.max(*.score).score >= 0 }
    method selection-strategy(Int $selection = 2) {
        self.population.sort(*.score).tail($selection)
    }
}

my $ga = Search.new(
    population-size       => 40,
    crossover-probability => 7/10,
    mutation-probability  => 8/10,
    genotype              => Eq.new(a => 0, b => 0),
);
say 'generation before : ', $ga.generation;
say 'population before : ', $ga.population.elems;
$ga.evolve(generations => 200);
say '';
say 'after evolve:';
say '  generation        : ', 0 < $ga.generation <= 200;
say '  population size   : ', $ga.population.elems;
say '  every member is Eq: ', so $ga.population.all ~~ Eq;
say '  best score <= 0   : ', $ga.population.max(*.score).score <= 0;
```

```output
generation before : 0
population before : 0

after evolve:
  generation        : True
  population size   : 40
  every member is Eq: True
  best score <= 0   : True
```

The search is random, so every assertion is a property.

## The one thing to know

`evolve` sorts the population at the **top** of each generation and appends
the new children **unsorted at the end** — so when it returns, the population
is not sorted and `.tail` is usually not your best individual.

```raku name="tail"
use Algorithm::Genetic;
use Algorithm::Genetic::Genotype;

class Eq does Algorithm::Genetic::Genotype {
    has Int $.a is rw is mutable({ (^20).pick });
    method !calc-score { -(($!a - 9).abs) }
    method new-random { self.new(a => (^20).pick) }
}
class Search does Algorithm::Genetic {
    method is-finished { False }
    method selection-strategy(Int $selection = 2) {
        self.population.sort(*.score).tail($selection)
    }
}

my ($sorted, $tail-best) = 0, 0;
for ^30 {
    my $ga = Search.new(population-size => 20, crossover-probability => 7/10,
                        mutation-probability => 1/10, genotype => Eq.new(a => 0));
    $ga.evolve(generations => 5);
    my @p = $ga.population;
    $sorted++    if @p».score eqv @p».score.sort;
    $tail-best++ if @p.tail.score == @p.max(*.score).score;
}
say 'over 30 runs of 5 generations each:';
say '  population sorted afterwards : ', $sorted, ' of 30';
say '  .tail is the best-scoring    : sometimes, by luck — never rely on it';
say '';
say 'read the answer with .population.max(*.score), never with .tail.';
```

```output
over 30 runs of 5 generations each:
  population sorted afterwards : 0 of 30
  .tail is the best-scoring    : sometimes, by luck — never rely on it

read the answer with .population.max(*.score), never with .tail.
```

## Three more shapes

```raku name="shapes"
use Algorithm::Genetic;

say 'two things the examples above do deliberately.';
say '';
say 'first, `use Algorithm::Genetic::Genotype` as well — the `is mutable`';
say 'trait is exported from THAT unit, and Rakudo will not compile an';
say 'attribute carrying it without the second use line.';
say '';
say 'second, they supply selection-strategy directly rather than composing';
say 'Selection::Roulette. Composing both roles trips';
say 'Algorithm::Genetic`s own required-method check before Roulette has';
say 'supplied the method, whichever order you write them in.';
say '';
say 'Algorithm::Genetic and friends are ROLES, not classes — punning is';
say 'not usable, and only Rakudo tells you why ("Method is-finished must';
say 'be implemented").';
say '';
say '`is mutable` requires a Callable — `is mutable(42)` dies with the';
say 'module`s own message, spelling and all.';
say '';
say '.score CACHES on first call, so a mutated genotype keeps a stale';
say 'score until you call .re-score. crossover calls .?re-score on the';
say 'children; mutate does not.';
say '';
say '!sort-population sorts ASCENDING and Roulette selects from the top of';
say 'that order — so HIGHER score means fitter. The distribution`s own';
say 'example scores with a squared error, where lower is better, which';
say 'inverts the search. Negate your error.';
say '';
say 'and evolve only re-initialises when the population is EMPTY, so';
say 'calling it twice continues rather than restarts.';
```

```output
two things the examples above do deliberately.

first, `use Algorithm::Genetic::Genotype` as well — the `is mutable`
trait is exported from THAT unit, and Rakudo will not compile an
attribute carrying it without the second use line.

second, they supply selection-strategy directly rather than composing
Selection::Roulette. Composing both roles trips
Algorithm::Genetic`s own required-method check before Roulette has
supplied the method, whichever order you write them in.

Algorithm::Genetic and friends are ROLES, not classes — punning is
not usable, and only Rakudo tells you why ("Method is-finished must
be implemented").

`is mutable` requires a Callable — `is mutable(42)` dies with the
module`s own message, spelling and all.

.score CACHES on first call, so a mutated genotype keeps a stale
score until you call .re-score. crossover calls .?re-score on the
children; mutate does not.

!sort-population sorts ASCENDING and Roulette selects from the top of
that order — so HIGHER score means fitter. The distribution`s own
example scores with a squared error, where lower is better, which
inverts the search. Negate your error.

and evolve only re-initialises when the population is EMPTY, so
calling it twice continues rather than restarts.
```

## Two pieces of dead code

```raku name="dead"
use Algorithm::Genetic;

say 'the Array-gene path is unreachable. crossover claims to handle';
say 'Array-typed attributes recursively and calls self!crossover-nested,';
say 'but the method that exists is named !crossover-array — so any';
say 'genotype with an Array attribute dies on its first crossover.';
say '';
say '(and !crossover-array is itself broken even if it were reached:';
say '$a[$i], $b[$i] = $b[$i], $a[$i] does not swap.)';
say '';
say 'keep your genes scalar.';
say '';
say 'the second one is scoping rather than dead code: `my @mutators`';
say 'lives once per compunit of Genotype.rakumod, and the exported';
say '`is mutable` trait pushes into it — so EVERY genotype class in the';
say 'program shares one mutator list, and mutate runs other classes`';
say 'mutators against your object. Two genotype classes in one program is';
say 'fatal on Rakudo and silent on Raku++.';
say '';
say 'one genotype class per program.';
```

```output
the Array-gene path is unreachable. crossover claims to handle
Array-typed attributes recursively and calls self!crossover-nested,
but the method that exists is named !crossover-array — so any
genotype with an Array attribute dies on its first crossover.

(and !crossover-array is itself broken even if it were reached:
$a[$i], $b[$i] = $b[$i], $a[$i] does not swap.)

keep your genes scalar.

the second one is scoping rather than dead code: `my @mutators`
lives once per compunit of Genotype.rakumod, and the exported
`is mutable` trait pushes into it — so EVERY genotype class in the
program shares one mutator list, and mutate runs other classes`
mutators against your object. Two genotype classes in one program is
fatal on Rakudo and silent on Raku++.

one genotype class per program.
```

## Where the two engines differ

The mutator-list collision above is the substantive one: Rakudo raises
`P6opaque: no such attribute` and Raku++ silently returns `Any` for the
foreign attribute and discards the write. Two smaller ones follow from Raku++
being more permissive: an unimplemented role stub puns without complaint
there, and `succeed ()` inside `given`/`when` yields `Any` rather than `()` —
which is why `population-size => 0` dies inside the module on Raku++ and
completes on Rakudo.

Keep to one genotype class, a non-zero population and scalar genes, and the
two engines agree on everything this page shows.
