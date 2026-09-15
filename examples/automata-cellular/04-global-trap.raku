#!/usr/bin/env rakupp
# Automata::Cellular — The one thing to know
# https://raku.online/modules/automata-cellular/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Automata::Cellular
#     rakupp 04-global-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Automata::Cellular;

say 'the two names the module puts into GLOBAL:';
say '  Wolfram : ', ::('Wolfram').^name;
say '  Rule    : ', ::('Rule').^name;
say '';
say 'those are maximally generic names in the GLOBAL namespace.';
say 'declaring your own `class Rule` — the single most natural name';
say 'in a program about rule-based automata — collides with this one.';

# Output:
#     the two names the module puts into GLOBAL:
#       Wolfram : Wolfram
#       Rule    : Rule
#     
#     those are maximally generic names in the GLOBAL namespace.
#     declaring your own `class Rule` — the single most natural name
#     in a program about rule-based automata — collides with this one.
