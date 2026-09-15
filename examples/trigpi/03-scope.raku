#!/usr/bin/env rakupp
# TrigPi — What the claim does and does not cover
# https://raku.online/modules/trigpi/#what-the-claim-does-and-does-not-cover
#
# Install what it needs, then run it:
#     rakupp install TrigPi
#     rakupp 03-scope.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TrigPi;

say 'the accuracy claim covers the REDUCTION, not the underlying sin:';
say '  sinPi(1/6) == 1/2 ? ', sinPi(1/6) == 1/2, '   value ', sinPi(1/6);
say '  cosPi(1/3) == 1/2 ? ', cosPi(1/3) == 1/2, '   value ', cosPi(1/3);
say '  those are bit-identical to sin(pi/6) and cos(pi/3).';
say '';
say 'and the return TYPE is not stable — at half-integers you get an Int:';
for 0, 0.5, 1, 1.5 -> $x {
    say sprintf('  sinPi(%-4s) %-4s   cosPi(%-4s) %s',
                $x, sinPi($x).WHAT.^name, $x, cosPi($x).WHAT.^name);
}
say '';
say 'the declared return type is Real, so this is legal — and it means';
say 'sinPi(1/2) is an exact Int 1 while sinPi(1) is a Num negative zero.';
say '';
say 'huge and exact arguments are both fine:';
say '  sinPi(10**20)      = ', sinPi(10**20);
say '  cosPi(FatRat.new(1, 3)).round(0.0001) = ',
    cosPi(FatRat.new(1, 3)).round(0.0001);

# Output:
#     the accuracy claim covers the REDUCTION, not the underlying sin:
#       sinPi(1/6) == 1/2 ? False   value 0.49999999999999994
#       cosPi(1/3) == 1/2 ? False   value 0.5000000000000001
#       those are bit-identical to sin(pi/6) and cos(pi/3).
#     
#     and the return TYPE is not stable — at half-integers you get an Int:
#       sinPi(0   ) Num    cosPi(0   ) Num
#       sinPi(0.5 ) Int    cosPi(0.5 ) Int
#       sinPi(1   ) Num    cosPi(1   ) Num
#       sinPi(1.5 ) Int    cosPi(1.5 ) Int
#     
#     the declared return type is Real, so this is legal — and it means
#     sinPi(1/2) is an exact Int 1 while sinPi(1) is a Num negative zero.
#     
#     huge and exact arguments are both fine:
#       sinPi(10**20)      = 0
#       cosPi(FatRat.new(1, 3)).round(0.0001) = 0.5
