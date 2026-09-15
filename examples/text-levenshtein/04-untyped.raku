#!/usr/bin/env rakupp
# Text::Levenshtein — Where the two engines differ
# https://raku.online/modules/text-levenshtein/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Text::Levenshtein
#     rakupp 04-untyped.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Levenshtein;

say 'the sub is untyped, so anything that stringifies works:';
say '  distance(12, 13)     = ', distance(12, 13).raku;
say '  distance("1", 1)     = ', distance('1', 1).raku;
say '  distance(1.0, 1)     = ', distance(1.0, 1).raku, '   <- "1" vs "1"';
say '';
say '*@t is a FLATTENING slurpy, so a list is spread into separate targets:';
my @a = <four foo>;
say '  distance("foo", @a, "bar") = ', distance('foo', @a, 'bar').raku;
say '  you cannot pass a list as one target.';

# Output:
#     the sub is untyped, so anything that stringifies works:
#       distance(12, 13)     = [1]
#       distance("1", 1)     = [0]
#       distance(1.0, 1)     = [0]   <- "1" vs "1"
#     
#     *@t is a FLATTENING slurpy, so a list is spread into separate targets:
#       distance("foo", @a, "bar") = [2, 0, 3]
#       you cannot pass a list as one target.
