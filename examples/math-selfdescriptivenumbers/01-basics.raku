#!/usr/bin/env rakupp
# Math::SelfDescriptiveNumbers — Asking
# https://raku.online/modules/math-selfdescriptivenumbers/#asking
#
# Install what it needs, then run it:
#     rakupp install Math::SelfDescriptiveNumbers
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::SelfDescriptiveNumbers;

for 1 .. 12 -> $b {
    my $r = self-descriptive-numbers-of($b);
    say sprintf('  base %2d : %s', $b, $r.elems ?? $r.raku !! '(none)');
}
say '';
say 'base 10 gives 6210001000, which is the published answer.';

# Output:
#       base  1 : (none)
#       base  2 : (none)
#       base  3 : (none)
#       base  4 : $("1210", "2020")
#       base  5 : "21200"
#       base  6 : (none)
#       base  7 : "3211000"
#       base  8 : "42101000"
#       base  9 : "521001000"
#       base 10 : "6210001000"
#       base 11 : "72100001000"
#       base 12 : "821000001000"
#     
#     base 10 gives 6210001000, which is the published answer.
