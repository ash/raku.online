#!/usr/bin/env rakupp
# Text::Levenshtein — Measuring a distance
# https://raku.online/modules/text-levenshtein/#measuring-a-distance
#
# Install what it needs, then run it:
#     rakupp install Text::Levenshtein
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Levenshtein;

say 'distance("kitten", "sitting")   = ', distance('kitten', 'sitting');
say 'distance("foo", <four foo bar>) = ', distance('foo', <four foo bar>);
say 'distance("", "abc")             = ', distance('', 'abc');
say 'distance("abc", "")             = ', distance('abc', '');
say 'distance("abc") with no target  = ', distance('abc');
say '';
say 'comparison is case-sensitive and does no folding:';
say '  distance("ABC", "abc")        = ', distance('ABC', 'abc');

# Output:
#     distance("kitten", "sitting")   = [3]
#     distance("foo", <four foo bar>) = [2 0 3]
#     distance("", "abc")             = [3]
#     distance("abc", "")             = [3]
#     distance("abc") with no target  = []
#     
#     comparison is case-sensitive and does no folding:
#       distance("ABC", "abc")        = [3]
