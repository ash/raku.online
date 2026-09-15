#!/usr/bin/env rakupp
# TrigPi — The win
# https://raku.online/modules/trigpi/#the-win
#
# Install what it needs, then run it:
#     rakupp install TrigPi
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TrigPi;

say 'sinPi(1)   == 0 exactly  : ', sinPi(1) == 0,   '      sin(pi)   = ', sin(pi);
say 'cosPi(1)   == -1 exactly : ', cosPi(1) == -1,  '      cos(pi)   = ', cos(pi);
say 'sinPi(1/2) == 1 exactly  : ', sinPi(1/2) == 1;
say 'cosPi(1/2) == 0 exactly  : ', cosPi(1/2) == 0, '      cos(pi/2) = ', cos(pi/2);
say 'sinPi(1e6) == 0 exactly  : ', sinPi(1e6) == 0;
say '  sin(pi*1e6) = ', sin(pi * 1e6);
say '';
say '|cisPi(x)| is exactly 1 at the quarter points:';
for 0, 1/4, 1/3, 1/2, 1 -> $x {
    say sprintf('  cisPi(%-4s) abs = %s', $x, cisPi($x).abs);
}

# Output:
#     sinPi(1)   == 0 exactly  : True      sin(pi)   = 1.2246467991473532e-16
#     cosPi(1)   == -1 exactly : True      cos(pi)   = -1
#     sinPi(1/2) == 1 exactly  : True
#     cosPi(1/2) == 0 exactly  : True      cos(pi/2) = 6.123233995736766e-17
#     sinPi(1e6) == 0 exactly  : True
#       sin(pi*1e6) = -2.231912181360871e-10
#     
#     |cisPi(x)| is exactly 1 at the quarter points:
#       cisPi(0   ) abs = 1
#       cisPi(0.25) abs = 1
#       cisPi(0.333333) abs = 1
#       cisPi(0.5 ) abs = 1
#       cisPi(1   ) abs = 1
