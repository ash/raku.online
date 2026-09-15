#!/usr/bin/env rakupp
# Unicode::PRECIS — Comparison
# https://raku.online/modules/unicode-precis/#comparison
#
# Install what it needs, then run it:
#     rakupp install Unicode::PRECIS
#     rakupp 02-compare.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Unicode::PRECIS;
use Unicode::PRECIS::Identifier::UsernameCaseMapped;

my $cm = Unicode::PRECIS::Identifier::UsernameCaseMapped.new;

say 'case folding:';
say '  compare("BobSmith", "bobsmith") : ', $cm.compare('BobSmith', 'bobsmith');
say '';
my $latin = 'paypal';
my $spoof = "p\c[CYRILLIC SMALL LETTER A]yp\c[CYRILLIC SMALL LETTER A]l";
say 'a Cyrillic homograph:';
say '  they render identically       : ', $latin.chars == $spoof.chars;
say '  codepoints differ             : ', $latin.ords ne $spoof.ords;
say '  compare says                  : ', $cm.compare($latin, $spoof);

# Output:
#     case folding:
#       compare("BobSmith", "bobsmith") : True
#     
#     a Cyrillic homograph:
#       they render identically       : True
#       codepoints differ             : True
#       compare says                  : False
