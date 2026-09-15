#!/usr/bin/env rakupp
# Game::Stats — Samples and their moments
# https://raku.online/modules/game-stats/#samples-and-their-moments
#
# Install what it needs, then run it:
#     rakupp install Game::Stats
#     rakupp 01-samples.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     3,1,4,1,5
#     3 5
#     sum       1
#     mean      0.25
#     variance  0.016667
#     cumulative to index 2: 0.3
