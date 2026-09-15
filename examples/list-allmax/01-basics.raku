#!/usr/bin/env rakupp
# List::Allmax — Both forms
# https://raku.online/modules/list-allmax/#both-forms
#
# Install what it needs, then run it:
#     rakupp install List::Allmax
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use List::Allmax;

my @a = 3, 1, 4, 1, 5, 9, 2, 6;
say 'all-max(@a)      : ', all-max(@a).raku;
say 'all-min(@a)      : ', all-min(@a).raku;
say 'all-max(@a, :k)  : ', all-max(@a, :k).raku;
say 'all-min(@a, :k)  : ', all-min(@a, :k).raku;
say '';
say 'a genuine tie returns every winner:';
say '  all-max(7, 2, 7, 3, 7) = ', all-max(7, 2, 7, 3, 7).raku;
say '';
say 'edges:';
say '  all-max()   = ', all-max().raku;
say '  all-max(42) = ', all-max(42).raku;
say '  the result is always an Array.';

# Output:
#     all-max(@a)      : [9]
#     all-min(@a)      : [1, 1]
#     all-max(@a, :k)  : [5]
#     all-min(@a, :k)  : [1, 3]
#     
#     a genuine tie returns every winner:
#       all-max(7, 2, 7, 3, 7) = [7, 7, 7]
#     
#     edges:
#       all-max()   = []
#       all-max(42) = [42]
#       the result is always an Array.
