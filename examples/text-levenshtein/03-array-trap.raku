#!/usr/bin/env rakupp
# Text::Levenshtein — The one thing to know
# https://raku.online/modules/text-levenshtein/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::Levenshtein
#     rakupp 03-array-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Levenshtein;

my $d = distance('foo', 'four');
say 'distance("foo","four")          = ', $d.raku;
say '  == 2                          ? ', ($d == 2).raku, '   <- the real distance';
say '  == 1                          ? ', ($d == 1).raku, '   <- the target COUNT';
say '';
say 'distance("foo","foo") == 0      ? ', (distance('foo','foo') == 0).raku;
say 'distance("a","zzzzzzzzzz") < 3  ? ', (distance('a','zzzzzzzzzz') < 3).raku,
    '   <- the real distance is ', distance('a','zzzzzzzzzz')[0];
say '';
say 'the right way is to subscript:';
say '  distance("a","zzzzzzzzzz")[0] = ', distance('a','zzzzzzzzzz')[0];

# Output:
#     distance("foo","four")          = $[2]
#       == 2                          ? Bool::False   <- the real distance
#       == 1                          ? Bool::True   <- the target COUNT
#     
#     distance("foo","foo") == 0      ? Bool::False
#     distance("a","zzzzzzzzzz") < 3  ? Bool::True   <- the real distance is 10
#     
#     the right way is to subscript:
#       distance("a","zzzzzzzzzz")[0] = 10
