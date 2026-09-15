#!/usr/bin/env rakupp
# Algorithm::Genetic — Composing it
# https://raku.online/modules/algorithm-genetic/#composing-it
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Genetic
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     generation before : 0
#     population before : 0
#     
#     after evolve:
#       generation        : True
#       population size   : 40
#       every member is Eq: True
#       best score <= 0   : True
