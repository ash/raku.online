#!/usr/bin/env rakupp
# Statistics::LinearRegression — Fitting
# https://raku.online/modules/statistics-linearregression/#fitting
#
# Install what it needs, then run it:
#     rakupp install Statistics::LinearRegression
#     rakupp 02-two-forms.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::LinearRegression;

my $fit = LR.new([1, 2, 3], [3, 2, 1]);
say 'from data       : ', $fit.get-parameters.raku;
my $line = LR.new(7, 3);
say 'from parameters : ', $line.get-parameters.raku, '  (slope 7, intercept 3)';
say '  at x = 2      : ', $line.at(2);
say '';
say 'two numbers are parameters, two lists are data, and nothing warns if';
say 'you mix them up.';
say '';
say 'the four helper subs are behind an import tag:';
say '  use Statistics::LinearRegression :ALL;';
say '  calc-slope, calc-intercept, get-parameters, value-at';
say 'a plain `use` gives you LR only.';

# Output:
#     from data       : (-1.0, 4.0)
#     from parameters : (7, 3)  (slope 7, intercept 3)
#       at x = 2      : 17
#     
#     two numbers are parameters, two lists are data, and nothing warns if
#     you mix them up.
#     
#     the four helper subs are behind an import tag:
#       use Statistics::LinearRegression :ALL;
#       calc-slope, calc-intercept, get-parameters, value-at
#     a plain `use` gives you LR only.
