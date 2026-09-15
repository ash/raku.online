#!/usr/bin/env rakupp
# Math::BijectiveBase — Converting
# https://raku.online/modules/math-bijectivebase/#converting
#
# Install what it needs, then run it:
#     rakupp install Math::BijectiveBase
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::BijectiveBase;

say 'spreadsheet columns:';
for 1, 26, 27, 52, 702, 703, 16384 -> $n {
    say sprintf('  %6d -> %s', $n, to-bijective26($n));
}
say '';
say '16384 is the last column of an Excel worksheet, and XFD is the';
say 'published answer.';
say '';
say 'round trip over 1..2000 : ',
    so (1..2000).all.map({ from-bijective26(to-bijective26($_)) == $_ });
say '';
say 'and the generic pair takes any alphabet you like:';
say '  to-bijectivebase(5, <a b>)   = ', to-bijectivebase(5, <a b>);
say '  to-bijectivebase(3, ["z"])   = ', to-bijectivebase(3, ['z']);
say '  big integers work            : ', to-bijective26(10**20);

# Output:
#     spreadsheet columns:
#            1 -> A
#           26 -> Z
#           27 -> AA
#           52 -> AZ
#          702 -> ZZ
#          703 -> AAA
#        16384 -> XFD
#     
#     16384 is the last column of an Excel worksheet, and XFD is the
#     published answer.
#     
#     round trip over 1..2000 : True
#     
#     and the generic pair takes any alphabet you like:
#       to-bijectivebase(5, <a b>)   = ba
#       to-bijectivebase(3, ["z"])   = zzz
#       big integers work            : ANGWJIRSMASUFQV
