#!/usr/bin/env rakupp
# Automata::Cellular — The rule table
# https://raku.online/modules/automata-cellular/#the-rule-table
#
# Install what it needs, then run it:
#     rakupp install Automata::Cellular
#     rakupp 03-table.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Automata::Cellular;

my $r = Rule.new(number => 30);
say $r.Str;
say 'Rule.Numeric    : ', $r.Numeric;
say 'Wolfram.Numeric : ', Wolfram.new(number => 110, width => 9).Numeric;

# Output:
#     Rule 30 subrules:
#     000 => 0
#     001 => 1
#     010 => 1
#     011 => 1
#     100 => 1
#     101 => 0
#     110 => 0
#     111 => 0
#     
#     Rule.Numeric    : 30
#     Wolfram.Numeric : 110
