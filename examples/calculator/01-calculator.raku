#!/usr/bin/env rakupp
# Calculator — Using it
# https://raku.online/modules/calculator/#using-it
#
# Install what it needs, then run it:
#     rakupp install Calculator
#     rakupp 01-calculator.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Calculator;

my $c = Calculator.new(x => 10, y => 3);
say 'x = ', $c.x, '   y = ', $c.y;
say '';
say 'add       -> ', $c.add;
say 'substract -> ', $c.substract;
say 'multiply  -> ', $c.multiply;
say 'divide    -> ', $c.divide, '   (a ', $c.divide.^name, ', exactly ',
    $c.divide.nude.join('/'), ')';

# Output:
#     x = 10   y = 3
#     
#     add       -> 13
#     substract -> 7
#     multiply  -> 30
#     divide    -> 3.333333   (a Rat, exactly 10/3)
