#!/usr/bin/env rakupp
# Lingua::Conjunction — The switches
# https://raku.online/modules/lingua-conjunction/#the-switches
#
# Install what it needs, then run it:
#     rakupp install Lingua::Conjunction
#     rakupp 02-switches.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Conjunction;

say 'default          : ', conjunction(<a b c>);
say ':last (Oxford)   : ', conjunction(<a b c>, :last);
say ':!last (no comma): ', conjunction(<a b c>, :!last);
say '';
say 'a template       : ', conjunction(<a b c>, :str('I want |list| today'));
say '';
say 'empty list       : ', conjunction().raku;
say 'one item         : ', conjunction('solo').raku;

# Output:
#     default          : a, b, and c
#     :last (Oxford)   : a, b, and c
#     :!last (no comma): a, b and c
#     
#     a template       : I want a, b, and c today
#     
#     empty list       : ""
#     one item         : "solo"
