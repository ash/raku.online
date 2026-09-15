#!/usr/bin/env rakupp
# Gray::Code::RBC — The one thing to know
# https://raku.online/modules/gray-code-rbc/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Gray::Code::RBC
#     rakupp 04-negative-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Gray::Code::RBC;

for -4 .. 2 -> $n {
    my $g = gray-encode($n);
    say sprintf('gray-encode(%2d) = %d   round trip -> %2d   %s',
        $n, $g, gray-decode($g), gray-decode($g) == $n ?? 'ok' !! 'LOST');
}
say '';
say 'encode(-1) == encode(0) : ', gray-encode(-1) == gray-encode(0);

# Output:
#     gray-encode(-4) = 2   round trip ->  3   LOST
#     gray-encode(-3) = 3   round trip ->  2   LOST
#     gray-encode(-2) = 1   round trip ->  1   LOST
#     gray-encode(-1) = 0   round trip ->  0   LOST
#     gray-encode( 0) = 0   round trip ->  0   ok
#     gray-encode( 1) = 1   round trip ->  1   ok
#     gray-encode( 2) = 3   round trip ->  2   ok
#     
#     encode(-1) == encode(0) : True
