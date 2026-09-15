#!/usr/bin/env rakupp
# Math::Polynomial::Chebyshev — Evaluating
# https://raku.online/modules/math-polynomial-chebyshev/#evaluating
#
# Install what it needs, then run it:
#     rakupp install Math::Polynomial::Chebyshev
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Polynomial::Chebyshev;

say 'T_n(x) at x = 0.5:';
for 0 .. 5 -> $k {
    say sprintf('  T_%d(0.5) = %s', $k, chebyshev-t($k, 0.5));
}
say '';
say 'the identities, exactly:';
say '  T_n(1)     for n=0..8 : ', (0..8).map({ chebyshev-t($_, 1) }).join(', ');
say '  T_n(-1)    for n=0..6 : ', (0..6).map({ chebyshev-t($_, -1) }).join(', ');
say '  U_n(1)     for n=0..6 : ', (0..6).map({ chebyshev-u($_, 1) }).join(', ');
say '';
say 'and they hold far out:';
say '  T_200(1)  = ', chebyshev-t(200, 1);
say '  U_200(1)  = ', chebyshev-u(200, 1);

# Output:
#     T_n(x) at x = 0.5:
#       T_0(0.5) = 1
#       T_1(0.5) = 0.5
#       T_2(0.5) = -0.5
#       T_3(0.5) = -1
#       T_4(0.5) = -0.5
#       T_5(0.5) = 0.5
#     
#     the identities, exactly:
#       T_n(1)     for n=0..8 : 1, 1, 1, 1, 1, 1, 1, 1, 1
#       T_n(-1)    for n=0..6 : 1, -1, 1, -1, 1, -1, 1
#       U_n(1)     for n=0..6 : 1, 2, 3, 4, 5, 6, 7
#     
#     and they hold far out:
#       T_200(1)  = 1
#       U_200(1)  = 201
