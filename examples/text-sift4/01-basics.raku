#!/usr/bin/env rakupp
# Text::Sift4 — Using it
# https://raku.online/modules/text-sift4/#using-it
#
# Install what it needs, then run it:
#     rakupp install Text::Sift4
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Sift4;

for <abc ab>, <ab abc>, <abc xxx>, <kitten sitting>, <abc abc> -> ($a, $b) {
    say sprintf('sift4(%-8s, %-8s) = %d', $a.raku, $b.raku, sift4($a, $b));
}
say '';
say 'return type : ', sift4('a', 'b').WHAT.^name;
say 'empty pair  : ', sift4('', '');
say 'undefined   : ', sift4(Str, 'abc'), '  (the parameters are Str, not Str:D)';

# Output:
#     sift4("abc"   , "ab"    ) = 1
#     sift4("ab"    , "abc"   ) = 1
#     sift4("abc"   , "xxx"   ) = 3
#     sift4("kitten", "sitting") = 3
#     sift4("abc"   , "abc"   ) = 0
#     
#     return type : Int
#     empty pair  : 0
#     undefined   : 3  (the parameters are Str, not Str:D)
