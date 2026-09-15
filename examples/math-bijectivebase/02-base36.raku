#!/usr/bin/env rakupp
# Math::BijectiveBase — The one thing to know
# https://raku.online/modules/math-bijectivebase/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::BijectiveBase
#     rakupp 02-base36.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::BijectiveBase;

say 'the 36 alphabet is  flat("1".."9", "A".."Z")  — nine digits plus';
say 'twenty-six letters is THIRTY-FIVE symbols, and "0" is not one:';
say '';
for 9, 10, 35, 36, 37 -> $n {
    say sprintf('  %3d -> %s', $n, to-bijective36($n));
}
say '';
say 'the first n whose output is two characters is 36, so the radix is 35.';
say '';
say 'the pair round-trips perfectly with itself, so nothing ever';
say 'complains — but a string produced by to-bijective36 is not base-36';
say 'anything, and real base-36 text containing 0 is rejected:';
my $r = try from-bijective36('10');
say '  from-bijective36("10") -> ', $! ?? 'refused' !! $r;
say '';
say 'round trip 1..500 : ',
    so (1..500).all.map({ from-bijective36(to-bijective36($_)) == $_ });

# Output:
#     the 36 alphabet is  flat("1".."9", "A".."Z")  — nine digits plus
#     twenty-six letters is THIRTY-FIVE symbols, and "0" is not one:
#     
#         9 -> 9
#        10 -> A
#        35 -> Z
#        36 -> 11
#        37 -> 12
#     
#     the first n whose output is two characters is 36, so the radix is 35.
#     
#     the pair round-trips perfectly with itself, so nothing ever
#     complains — but a string produced by to-bijective36 is not base-36
#     anything, and real base-36 text containing 0 is rejected:
#       from-bijective36("10") -> refused
#     
#     round trip 1..500 : True
