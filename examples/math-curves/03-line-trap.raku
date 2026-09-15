#!/usr/bin/env rakupp
# Math::Curves — The one thing to know
# https://raku.online/modules/math-curves/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::Curves
#     rakupp 03-line-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Curves;

for (2, 1/2), (10, 1/1), (4, 0/1), (5, 2/1) -> ($x, $g) {
    say sprintf('line(%2d, %-5s) = %-8s   x * g would be %s',
        $x, $g.raku, line($x, $g).raku, ($x * $g).raku);
}
say '';
say 'so a "gradient" of 0 is the identity rather than a flat line,';
say 'and the function never passes through the origin except at x = 0.';

# Output:
#     line( 2, 0.5  ) = 3.0        x * g would be 1.0
#     line(10, 1.0  ) = 20.0       x * g would be 10.0
#     line( 4, 0.0  ) = 4.0        x * g would be 0.0
#     line( 5, 2.0  ) = 15.0       x * g would be 10.0
#     
#     so a "gradient" of 0 is the identity rather than a flat line,
#     and the function never passes through the origin except at x = 0.
