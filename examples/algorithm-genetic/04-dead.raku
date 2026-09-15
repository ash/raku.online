#!/usr/bin/env rakupp
# Algorithm::Genetic — Two pieces of dead code
# https://raku.online/modules/algorithm-genetic/#two-pieces-of-dead-code
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Genetic
#     rakupp 04-dead.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     the Array-gene path is unreachable. crossover claims to handle
#     Array-typed attributes recursively and calls self!crossover-nested,
#     but the method that exists is named !crossover-array — so any
#     genotype with an Array attribute dies on its first crossover.
#     
#     (and !crossover-array is itself broken even if it were reached:
#     $a[$i], $b[$i] = $b[$i], $a[$i] does not swap.)
#     
#     keep your genes scalar.
#     
#     the second one is scoping rather than dead code: `my @mutators`
#     lives once per compunit of Genotype.rakumod, and the exported
#     `is mutable` trait pushes into it — so EVERY genotype class in the
#     program shares one mutator list, and mutate runs other classes`
#     mutators against your object. Two genotype classes in one program is
#     fatal on Rakudo and silent on Raku++.
#     
#     one genotype class per program.
