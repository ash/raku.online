#!/usr/bin/env rakupp
# TrigPi — The one thing to know
# https://raku.online/modules/trigpi/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install TrigPi
#     rakupp 02-negative-zero.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TrigPi;

for 0, 1, 2, 3, -1 -> $n {
    say sprintf('  sinPi(%-3d) gist = %s', $n, sinPi($n).gist);
}
say '';
say 'cisPi(1)        = ', cisPi(1);
say 'cisPi(1).im     = ', cisPi(1).im.gist;
say '';
say 'the reduction for 1 <= x < 2 is -sinPi($x - 1), and negating 0e0';
say 'gives -0e0.';
say '';
say 'ordinary comparisons are fine:';
say '  sinPi(1) == 0      : ', sinPi(1) == 0;
say '  sinPi(1).sign      : ', sinPi(1).sign;
say 'but identity and printing are not:';
say '  sinPi(1) === 0e0   : ', sinPi(1) === 0e0;
say '  it prints as       : ', sinPi(1).gist;
say '';
say 'anything that branches on the printed form, round-trips through a';
say 'string, or DIVIDES by the result will see the sign.';

# Output:
#       sinPi(0  ) gist = 0
#       sinPi(1  ) gist = -0
#       sinPi(2  ) gist = 0
#       sinPi(3  ) gist = -0
#       sinPi(-1 ) gist = 0
#     
#     cisPi(1)        = -1-0i
#     cisPi(1).im     = -0
#     
#     the reduction for 1 <= x < 2 is -sinPi($x - 1), and negating 0e0
#     gives -0e0.
#     
#     ordinary comparisons are fine:
#       sinPi(1) == 0      : True
#       sinPi(1).sign      : 0
#     but identity and printing are not:
#       sinPi(1) === 0e0   : False
#       it prints as       : -0
#     
#     anything that branches on the printed form, round-trips through a
#     string, or DIVIDES by the result will see the sign.
