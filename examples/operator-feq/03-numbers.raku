#!/usr/bin/env rakupp
# Operator::feq — The one thing to know
# https://raku.online/modules/operator-feq/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Operator::feq
#     rakupp 03-numbers.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Operator::feq;

my $eps = 0.1e0 + 0.2e0;
say '0.1e0 + 0.2e0     = ', $eps;
say 'differs from 0.3e0 by ', ($eps - 0.3e0);
say '  $eps feq 0.3e0  = ', ($eps feq 0.3e0), '   <- 5.5e-17 apart, and False';
say '  $eps == 0.3e0   = ', ($eps == 0.3e0);
say '';
say '1000000000 feq 1000000001 = ', (1000000000 feq 1000000001),
    '   <- a full unit apart, and True';
say '1.0e0 feq 2.0e0           = ', (1.0e0 feq 2.0e0);
say '3.14159e0 feq 3.14158e0   = ', (3.14159e0 feq 3.14158e0);
say '';
say '"0.30000000000000004" and "0.3" are sixteen edits apart out of';
say 'nineteen characters; "1000000000" and "1000000001" are one out of';
say 'ten. For numbers, use `=~=` or an explicit epsilon.';

# Output:
#     0.1e0 + 0.2e0     = 0.30000000000000004
#     differs from 0.3e0 by 5.551115123125783e-17
#       $eps feq 0.3e0  = False   <- 5.5e-17 apart, and False
#       $eps == 0.3e0   = False
#     
#     1000000000 feq 1000000001 = True   <- a full unit apart, and True
#     1.0e0 feq 2.0e0           = False
#     3.14159e0 feq 3.14158e0   = False
#     
#     "0.30000000000000004" and "0.3" are sixteen edits apart out of
#     nineteen characters; "1000000000" and "1000000001" are one out of
#     ten. For numbers, use `=~=` or an explicit epsilon.
