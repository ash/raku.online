#!/usr/bin/env rakupp
# Math::Polynomial::Chebyshev — The one thing to know
# https://raku.online/modules/math-polynomial-chebyshev/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::Polynomial::Chebyshev
#     rakupp 03-exact.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Polynomial::Chebyshev;

my $r = chebyshev-t(30, 1/3);
say 'chebyshev-t(30, 1/3):';
say '  type        : ', $r.WHAT.^name;
say '  numerator   : ', $r.numerator;
say '  denominator : ', $r.denominator;
say '';
say 'so == against a float literal fails, and .denominator is meaningful.';
say '';
say 'and the exactness stops without warning:';
for 10, 20, 40, 60, 80 -> $k {
    my $v = chebyshev-t($k, 1/3);
    say sprintf('  k=%-3d %-4s %.15f', $k, $v.WHAT.^name, $v);
}
say '';
say 'once the denominator passes 2**64 a Rat degrades to Num, and the';
say 'result type changes under you. Decide up front: use FatRat inputs if';
say 'you need exactness at large k, or accept Num throughout.';

# Output:
#     chebyshev-t(30, 1/3):
#       type        : Rat
#       numerator   : 147764231284649
#       denominator : 205891132094649
#     
#     so == against a float literal fails, and .denominator is meaningful.
#     
#     and the exactness stops without warning:
#       k=10  Rat  0.967213670002879
#       k=20  Rat  0.871004566880876
#       k=40  Rat  0.517297911054685
#       k=60  Num  0.030133119052260
#       k=80  Num  -0.464805742436918
#     
#     once the denominator passes 2**64 a Rat degrades to Num, and the
#     result type changes under you. Decide up front: use FatRat inputs if
#     you need exactness at large k, or accept Num throughout.
