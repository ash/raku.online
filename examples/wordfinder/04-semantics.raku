#!/usr/bin/env rakupp
# wordfinder — The matcher is not "contains"
# https://raku.online/modules/wordfinder/#the-matcher-is-not-contains
#
# Install what it needs, then run it:
#     rakupp install wordfinder
#     rakupp 04-semantics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use wordfinder;

say 'check_strings compares the DISTINCT-letter sets for equality:';
say '  "abc" vs "cabbage" : ', check_strings('abc', 'cabbage').raku, '  <- not a subset test';
say '  "abc" vs "abcd"    : ', check_strings('abc', 'abcd').raku,    '  <- nor a prefix test';
say '  "aabbcc" vs "abc"  : ', check_strings('aabbcc', 'abc').raku,  '  <- repetition ignored';
say '  "ABC" vs "abc"     : ', check_strings('ABC', 'abc').raku,     '  <- case-SENSITIVE';
say '';
say 'so what you get is "words that are anagram-set-equal to the query".';
say 'lower-case your input yourself.';

# Output:
#     check_strings compares the DISTINCT-letter sets for equality:
#       "abc" vs "cabbage" : Empty  <- not a subset test
#       "abc" vs "abcd"    : Empty  <- nor a prefix test
#       "aabbcc" vs "abc"  : "abc"  <- repetition ignored
#       "ABC" vs "abc"     : Empty  <- case-SENSITIVE
#     
#     so what you get is "words that are anagram-set-equal to the query".
#     lower-case your input yourself.
