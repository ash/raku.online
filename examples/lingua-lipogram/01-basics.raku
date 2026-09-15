#!/usr/bin/env rakupp
# Lingua::Lipogram — Asking
# https://raku.online/modules/lingua-lipogram/#asking
#
# Install what it needs, then run it:
#     rakupp install Lingua::Lipogram
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Lipogram;

say 'no "e" in "Lingua"      : ', lipogram('Lingua', 'e');
say 'but "e" is in "letter"  : ', lipogram('letter', 'e');
say 'case is folded          : ', lipogram('Elephant', 'e');
say '';
say 'several letters at once :';
say '  lipogram("rhythm", "aeiou") = ', lipogram('rhythm', 'aeiou');
say '  lipogram("syzygy", "aeiou") = ', lipogram('syzygy', 'aeiou');
say '';
say 'a Range works too       :';
say '  lipogram("xyz",  "a".."c") = ', lipogram('xyz',  'a'..'c');
say '  lipogram("xayz", "a".."c") = ', lipogram('xayz', 'a'..'c');

# Output:
#     no "e" in "Lingua"      : True
#     but "e" is in "letter"  : False
#     case is folded          : False
#     
#     several letters at once :
#       lipogram("rhythm", "aeiou") = True
#       lipogram("syzygy", "aeiou") = True
#     
#     a Range works too       :
#       lipogram("xyz",  "a".."c") = True
#       lipogram("xayz", "a".."c") = False
