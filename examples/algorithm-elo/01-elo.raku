#!/usr/bin/env rakupp
# Algorithm::Elo — Rating a game
# https://raku.online/modules/algorithm-elo/#rating-a-game
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Elo
#     rakupp 01-elo.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::Elo;

say 'equal ratings, left wins  : ', calculate-elo(1600, 1600, :left).List.raku;
say 'equal ratings, right wins : ', calculate-elo(1600, 1600, :right).List.raku;
say 'equal ratings, a draw     : ', calculate-elo(1600, 1600, :draw).List.raku;
say '';
say 'an 800-point underdog winning : ', calculate-elo(1200, 2000, :left).List.raku;
say 'the same favourite winning    : ', calculate-elo(2000, 1200, :left).List.raku;
say '';
my ($a, $b) = calculate-elo(1600, 1600, :left);
say 'return types  : ', $a.^name, ' ', $b.^name;
say 'total rating  : ', 1600 + 1600, ' before, ', $a + $b, ' after';

# Output:
#     equal ratings, left wins  : (1616, 1584)
#     equal ratings, right wins : (1584, 1616)
#     equal ratings, a draw     : (1600, 1600)
#     
#     an 800-point underdog winning : (1232, 1968)
#     the same favourite winning    : (2000, 1200)
#     
#     return types  : Int Int
#     total rating  : 3200 before, 3200 after
