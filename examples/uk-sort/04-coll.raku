#!/usr/bin/env rakupp
# UK::Sort — The one thing to know
# https://raku.online/modules/uk-sort/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install UK::Sort
#     rakupp 04-coll.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UK::Sort;

my @w = <їжак іній ирій йод>;
say 'sortuk         : ', sortuk(@w).join(' ');
say 'sort(&[coll])  : ', @w.sort(&[coll]).join(' ');
say 'plain .sort    : ', @w.sort.join(' ');
say '';
say 'cmp_uk("їжак","іній") = ', cmp_uk('їжак', 'іній'),
    '    "їжак" coll "іній" = ', ('їжак' coll 'іній');
say '';
say 'the two disagree, and cmp_uk is the one that is right: ї is the';
say '13th letter and і the 12th, so іній must come first. cmp_uk`s';
say 'letter-at-a-time loop forces each letter`s full weight to settle';
say 'before moving on; coll does not.';

# Output:
#     sortuk         : ирій іній їжак йод
#     sort(&[coll])  : ирій їжак іній йод
#     plain .sort    : ирій йод іній їжак
#     
#     cmp_uk("їжак","іній") = More    "їжак" coll "іній" = Less
#     
#     the two disagree, and cmp_uk is the one that is right: ї is the
#     13th letter and і the 12th, so іній must come first. cmp_uk`s
#     letter-at-a-time loop forces each letter`s full weight to settle
#     before moving on; coll does not.
