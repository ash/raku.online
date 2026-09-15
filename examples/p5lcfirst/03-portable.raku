#!/usr/bin/env rakupp
# P5lcfirst — Where the two engines differ
# https://raku.online/modules/p5lcfirst/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install P5lcfirst
#     rakupp 03-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5lcfirst;

say 'the end state of a port is core Raku:';
say '  "hello".tc     = ', 'hello'.tc.raku, '   <- titlecase the first character';
say '  "HELLO".lcfirst — no such method; use a substr:';
sub lc-first(Str $s) { $s.chars ?? $s.substr(0, 1).lc ~ $s.substr(1) !! $s }
say '  lc-first("HELLO") = ', lc-first('HELLO').raku;
say '';
say 'and if you specifically want the uppercase rather than the titlecase';
say 'first character, say so:';
sub uc-first(Str $s) { $s.chars ?? $s.substr(0, 1).uc ~ $s.substr(1) !! $s }
my $dz = "\c[LATIN SMALL LETTER DZ WITH CARON]";
say '  uc-first(dz) = ', uc-first($dz).raku, '   .tc = ', $dz.tc.raku;
say '';
say 'that is the decision this module makes for you, and the reason to';
say 'make it deliberately when the port is finished.';

# Output:
#     the end state of a port is core Raku:
#       "hello".tc     = "Hello"   <- titlecase the first character
#       "HELLO".lcfirst — no such method; use a substr:
#       lc-first("HELLO") = "hELLO"
#     
#     and if you specifically want the uppercase rather than the titlecase
#     first character, say so:
#       uc-first(dz) = "Ǆ"   .tc = "ǅ"
#     
#     that is the decision this module makes for you, and the reason to
#     make it deliberately when the port is finished.
