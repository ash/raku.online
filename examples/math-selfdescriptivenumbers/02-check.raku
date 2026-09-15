#!/usr/bin/env rakupp
# Math::SelfDescriptiveNumbers — Asking
# https://raku.online/modules/math-selfdescriptivenumbers/#asking
#
# Install what it needs, then run it:
#     rakupp install Math::SelfDescriptiveNumbers
#     rakupp 02-check.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::SelfDescriptiveNumbers;

sub describes(Str $s, Int $base) {
    my @d = $s.comb.map({ .parse-base($base) });
    (^$base).all.map({ @d[$_] // 0 == @d.grep($_).elems })
}
for 4, 5, 7, 10 -> $b {
    for self-descriptive-numbers-of($b).list -> $s {
        say sprintf('  base %2d  %-14s self-descriptive by definition : %s',
                    $b, $s, so describes($s, $b));
    }
}

# Output:
#       base  4  1210           self-descriptive by definition : True
#       base  4  2020           self-descriptive by definition : True
#       base  5  21200          self-descriptive by definition : True
#       base  7  3211000        self-descriptive by definition : True
#       base 10  6210001000     self-descriptive by definition : True
