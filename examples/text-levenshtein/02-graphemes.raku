#!/usr/bin/env rakupp
# Text::Levenshtein — Measuring a distance
# https://raku.online/modules/text-levenshtein/#measuring-a-distance
#
# Install what it needs, then run it:
#     rakupp install Text::Levenshtein
#     rakupp 02-graphemes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Levenshtein;

my $zwj = "\c[WOMAN]\c[ZERO WIDTH JOINER]\c[PERSONAL COMPUTER]";
say 'a ZWJ sequence: chars=', $zwj.chars, ' codepoints=', $zwj.ords.elems;
say '  distance("", it) = ', distance('', $zwj)[0];
say '';
my $cjk = "\c[CJK UNIFIED IDEOGRAPH-6F22]\c[CJK UNIFIED IDEOGRAPH-5B57]";
say 'two CJK ideographs, drop one: ', distance($cjk, $cjk.substr(0,1))[0];

# Output:
#     a ZWJ sequence: chars=1 codepoints=3
#       distance("", it) = 1
#     
#     two CJK ideographs, drop one: 1
