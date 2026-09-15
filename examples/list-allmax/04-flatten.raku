#!/usr/bin/env rakupp
# List::Allmax — Everything is flattened
# https://raku.online/modules/list-allmax/#everything-is-flattened
#
# Install what it needs, then run it:
#     rakupp install List::Allmax
#     rakupp 04-flatten.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use List::Allmax;

say 'the *@list slurpy flattens, so sub-arrays never survive:';
say '  all-max([1,2], [3], [0,9,9]) = ', all-max([1,2], [3], [0,9,9]).raku;
say '';
say 'with :k the indices are into the FLATTENED list, not into anything';
say 'you passed:';
say '  all-max([1,2], [3], [0,9,9], :k) = ', all-max([1,2], [3], [0,9,9], :k).raku;
say '';
say 'if you want to compare the sub-lists themselves, compare by a key:';
my @lists = [1, 2], [3], [0, 9, 9];
say '  longest sub-list : ', all-max(@lists, by => *.elems).raku;

# Output:
#     the *@list slurpy flattens, so sub-arrays never survive:
#       all-max([1,2], [3], [0,9,9]) = [9, 9]
#     
#     with :k the indices are into the FLATTENED list, not into anything
#     you passed:
#       all-max([1,2], [3], [0,9,9], :k) = [4, 5]
#     
#     if you want to compare the sub-lists themselves, compare by a key:
#       longest sub-list : [[0, 9, 9],]
