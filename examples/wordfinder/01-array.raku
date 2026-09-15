#!/usr/bin/env rakupp
# wordfinder — Matching against a list
# https://raku.online/modules/wordfinder/#matching-against-a-list
#
# Install what it needs, then run it:
#     rakupp install wordfinder
#     rakupp 01-array.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use wordfinder;

my @words = <eat ate tea eaten tar teal late>;
say 'check_array("tea", @words)     : ', check_array('tea', @words).raku;
say 'check_array("tea", @words, 3)  : ', check_array('tea', @words, 3).raku;
say '';
say 'the primitive underneath:';
for <abc cab>, <abc cabbage>, <abc abcd>, <aabbcc abc>, <ABC abc> -> ($a, $b) {
    say sprintf('  check_strings(%-10s, %-10s) = %s',
                $a.raku, $b.raku, check_strings($a, $b).raku);
}

# Output:
#     check_array("tea", @words)     : ["eat", "ate", "tea"]
#     check_array("tea", @words, 3)  : ["eat", "ate", "tea"]
#     
#     the primitive underneath:
#       check_strings("abc"     , "cab"     ) = "cab"
#       check_strings("abc"     , "cabbage" ) = Empty
#       check_strings("abc"     , "abcd"    ) = Empty
#       check_strings("aabbcc"  , "abc"     ) = "abc"
#       check_strings("ABC"     , "abc"     ) = Empty
