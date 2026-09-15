#!/usr/bin/env rakupp
# Algorithm::Genetic — The one thing to know
# https://raku.online/modules/algorithm-genetic/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Genetic
#     rakupp 02-tail.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     over 30 runs of 5 generations each:
#       population sorted afterwards : 0 of 30
#       .tail is the best-scoring    : sometimes, by luck — never rely on it
#     
#     read the answer with .population.max(*.score), never with .tail.
