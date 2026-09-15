#!/usr/bin/env rakupp
# Math::Polynomial::Chebyshev — Three argument shapes
# https://raku.online/modules/math-polynomial-chebyshev/#three-argument-shapes
#
# Install what it needs, then run it:
#     rakupp install Math::Polynomial::Chebyshev
#     rakupp 02-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Polynomial::Chebyshev;

say 'a number  : ', chebyshev-t(3, 2);
say 'a list    : ', chebyshev-t(3, (0, 0.5, 1)).raku;
say 'Whatever  : ', chebyshev-t(4).WHAT.^name, ' — a closure of one variable';
say '  applied : ', chebyshev-t(4).(0.5);
say '  check   : 8x^4 - 8x^2 + 1 at 0.5 = ', (8 * 0.5**4 - 8 * 0.5**2 + 1);
say '';
say 'complex arguments work and are right:';
my $z = chebyshev-t(3, 1+1i);
say '  T_3(1+1i) = ', $z;
my $closed = 4 * (1+1i)**3 - 3 * (1+1i);
say '  matches 4z^3 - 3z at z=1+i : ', abs($z - $closed) < 1e-12;

# Output:
#     a number  : 26
#     a list    : [0, -1.0, 1]
#     Whatever  : Block — a closure of one variable
#       applied : -0.5
#       check   : 8x^4 - 8x^2 + 1 at 0.5 = -0.5
#     
#     complex arguments work and are right:
#       T_3(1+1i) = -11+5i
#       matches 4z^3 - 3z at z=1+i : True
