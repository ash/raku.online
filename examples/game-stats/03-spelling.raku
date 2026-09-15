#!/usr/bin/env rakupp
# Game::Stats — The one thing to know
# https://raku.online/modules/game-stats/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Game::Stats
#     rakupp 03-spelling.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

say (try { EVAL 'use Game::Stats; 1' }) // 'use Game::Stats: not a unit';
say (try { EVAL 'use Game::Stats::Probablity; 1' }) // 'as shipped: no';
say (try { EVAL 'use Game::Stats::Probability; 1' }) // 'spelled right: no';
say (try { EVAL 'use Game::Stats::Probablity; Game::Stats::Probability.^name' })
    // 'the class: no';

# Output:
#     use Game::Stats: not a unit
#     1
#     spelled right: no
#     Game::Stats::Probability
