#!/usr/bin/env rakupp
# List::Allmax — Comparing by a key
# https://raku.online/modules/list-allmax/#comparing-by-a-key
#
# Install what it needs, then run it:
#     rakupp install List::Allmax
#     rakupp 02-by.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use List::Allmax;

my @words = <apple fig plum kiwi pear>;
say 'longest words  : ', all-max(@words, by => *.chars).raku;
say 'shortest words : ', all-min(@words, by => *.chars).raku;
say '';
say 'comparison is `cmp`, which is generic — so on Pairs it compares the';
say 'KEY first:';
my @pairs = (a => 1), (b => 3), (c => 3);
say '  all-max(@pairs)              = ', all-max(@pairs).raku;
say '  all-max(@pairs, by => +*.value) = ', all-max(@pairs, by => +*.value).raku;
say '';
say 'and a :by returning a Str compares lexicographically:';
say '  all-max(9, 10, 100, 2, by => *.Str) = ', all-max(9, 10, 100, 2, by => *.Str).raku;
say '  all-max(9, 10, 100, 2, by => +*)    = ', all-max(9, 10, 100, 2, by => +*).raku;

# Output:
#     longest words  : ["apple"]
#     shortest words : ["fig"]
#     
#     comparison is `cmp`, which is generic — so on Pairs it compares the
#     KEY first:
#       all-max(@pairs)              = [:c(3)]
#       all-max(@pairs, by => +*.value) = [:b(3), :c(3)]
#     
#     and a :by returning a Str compares lexicographically:
#       all-max(9, 10, 100, 2, by => *.Str) = [9]
#       all-max(9, 10, 100, 2, by => +*)    = [100]
