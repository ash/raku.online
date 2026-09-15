#!/usr/bin/env rakupp
# DateTime::Math — Converting units
# https://raku.online/modules/datetime-math/#converting-units
#
# Install what it needs, then run it:
#     rakupp install DateTime::Math
#     rakupp 01-units.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Math;

for <s m h d w M y> -> $u {
    say sprintf('1 %-2s = %12s seconds', $u, to-seconds(1, $u));
}
say '';
say 'from-seconds(86400, "h")      : ', from-seconds(86400, 'h');
say 'duration-from-to(1, "y", "d") : ', duration-from-to(1, 'y', 'd');
say 'duration-from-to(1, "d", "w") : ', duration-from-to(1, 'd', 'w');

# Output:
#     1 s  =            1 seconds
#     1 m  =           60 seconds
#     1 h  =         3600 seconds
#     1 d  =        86400 seconds
#     1 w  =       604800 seconds
#     1 M  =      2592000 seconds
#     1 y  =     31536000 seconds
#     
#     from-seconds(86400, "h")      : 24
#     duration-from-to(1, "y", "d") : 365
#     duration-from-to(1, "d", "w") : 0.142857
