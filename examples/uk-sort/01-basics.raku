#!/usr/bin/env rakupp
# UK::Sort — Sorting
# https://raku.online/modules/uk-sort/#sorting
#
# Install what it needs, then run it:
#     rakupp install UK::Sort
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UK::Sort;

my @words = <яблуко абрикос ґанок зебра іній їжак евкаліпт ежак банан>;
say 'plain .sort : ', @words.sort.join(' ');
say 'sortuk      : ', sortuk(@words).join(' ');
say '';
say 'and it folds case, which plain .sort does not:';
my @mixed = <Яблуко абрикос Банан>;
say '  plain .sort : ', @mixed.sort.join(' ');
say '  sortuk      : ', sortuk(@mixed).join(' ');

# Output:
#     plain .sort : абрикос банан евкаліпт ежак зебра яблуко іній їжак ґанок
#     sortuk      : абрикос банан ґанок евкаліпт ежак зебра іній їжак яблуко
#     
#     and it folds case, which plain .sort does not:
#       plain .sort : Банан Яблуко абрикос
#       sortuk      : абрикос Банан Яблуко
