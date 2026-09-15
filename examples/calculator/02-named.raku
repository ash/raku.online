#!/usr/bin/env rakupp
# Calculator — Named arguments only
# https://raku.online/modules/calculator/#named-arguments-only
#
# Install what it needs, then run it:
#     rakupp install Calculator
#     rakupp 02-named.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Calculator;

my $r = try Calculator.new(10, 3);
say 'positional arguments : ', $! ?? 'refused' !! 'accepted';
say 'named arguments      : ', Calculator.new(x => 10, y => 3).add;
say '';
my $n = try Calculator.new(x => 10);
say 'a missing y          : ', $! ?? 'refused' !! 'accepted';

# Output:
#     positional arguments : refused
#     named arguments      : 13
#     
#     a missing y          : refused
