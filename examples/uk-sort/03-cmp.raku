#!/usr/bin/env rakupp
# UK::Sort — The comparator
# https://raku.online/modules/uk-sort/#the-comparator
#
# Install what it needs, then run it:
#     rakupp install UK::Sort
#     rakupp 03-cmp.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UK::Sort;

say 'cmp_uk is exported too — note the underscore, not a hyphen:';
for <абрикос банан>, <ґанок абрикос>, <іній їжак>, <банан банан> -> ($a, $b) {
    say sprintf('  cmp_uk(%-10s, %-10s) = %s', $a.raku, $b.raku, cmp_uk($a, $b));
}
say '';
say 'sortuk has three candidates:';
say '  sortuk()          = ', sortuk().raku;
say '  sortuk("яблуко")  = ', sortuk('яблуко').raku;
say '  sortuk(@list)     returns a Seq';
say '';
say 'a single string is silently treated as a one-element list rather';
say 'than being an error.';

# Output:
#     cmp_uk is exported too — note the underscore, not a hyphen:
#       cmp_uk("абрикос" , "банан"   ) = Less
#       cmp_uk("ґанок"   , "абрикос" ) = More
#       cmp_uk("іній"    , "їжак"    ) = Less
#       cmp_uk("банан"   , "банан"   ) = Same
#     
#     sortuk has three candidates:
#       sortuk()          = ()
#       sortuk("яблуко")  = ("яблуко",)
#       sortuk(@list)     returns a Seq
#     
#     a single string is silently treated as a one-element list rather
#     than being an error.
