#!/usr/bin/env rakupp
# Game::Stats — Samples and their moments
# https://raku.online/modules/game-stats/#samples-and-their-moments
#
# Install what it needs, then run it:
#     rakupp install Game::Stats
#     rakupp 02-probability.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Game::Stats::Probablity;

my $P = Game::Stats::Probability.new(xpop => [0.2, 0.3, 0.5]);
say (^3).map({ $P.P($_) }).join(' ');
say 'and      ', $P.Pand(0, 0.5);
say 'or       ', $P.Por(0, 1, 0.5);
say 'cond     ', $P.CondP(0, 0.5);
say 'bayes    ', $P.Bayes([0, 1, 2], [0.9, 0.5, 0.1], 0);

# Output:
#     0.2 0.3 0.5
#     and      0.1
#     or       0.4
#     cond     0.5
#     bayes    0.473684
