#!/usr/bin/env rakupp
# Math::SpecialFunctions — Exact where it can be
# https://raku.online/modules/math-specialfunctions/#exact-where-it-can-be
#
# Install what it needs, then run it:
#     rakupp install Math::SpecialFunctions
#     rakupp 01-exact.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::SpecialFunctions;

say factorial(20);
say factorial(30);
say binomial(52, 5);
say bernoulli-b(12), ' = ', bernoulli-b(12).nude.join('/');
say bernoulli-b(2).^name, ' ', bernoulli-b(0).^name;

say gamma(0.5);
say gamma(0.5) ** 2;
say gamma(5);
say factorial(4);

# Output:
#     2432902008176640000
#     265252859812191058636308480000000
#     2598960
#     -0.253114 = -691/2730
#     FatRat Int
#     1.7724538509055163
#     3.1415926535897944
#     23.999999999999986
#     24
