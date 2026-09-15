#!/usr/bin/env rakupp
# Lingua::Lipogram — Where the two engines differ
# https://raku.online/modules/lingua-lipogram/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Lingua::Lipogram
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Lipogram;

# the module is pure and portable; only the shipped script is not
my $perec = 'Un long fauteuil, un tapis, un mur blanc';
say 'text : ', $perec;
say '  avoids "e" ?      ', lipogram($perec, 'e');
say '  avoids "aeiou" ?  ', lipogram($perec, 'aeiou');
say '';
say 'and the inverse question, which this module does not answer —';
say 'which forbidden letters actually occur — is one grep away:';
say '  offenders : ',
    'aeiou'.comb.grep({ !lipogram($perec, $_) }).join(' ');

# Output:
#     text : Un long fauteuil, un tapis, un mur blanc
#       avoids "e" ?      False
#       avoids "aeiou" ?  False
#     
#     and the inverse question, which this module does not answer —
#     which forbidden letters actually occur — is one grep away:
#       offenders : a e i o u
