#!/usr/bin/env rakupp
# sortuk — Sorting
# https://raku.online/modules/sortuk/#sorting
#
# Install what it needs, then run it:
#     rakupp install sortuk
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use SortUk;

my @words = <абрикос банан ґанок евкаліпт ежак зебра іній їжак яблуко>;
say 'plain .sort : ', @words.reverse.sort.join(' ');
say 'sortuk      : ', sortuk(@words.reverse).join(' ');
say '';
say 'and it folds case, which plain .sort does not:';
my @mixed = <Яблуко абрикос Банан>;
say '  plain .sort : ', @mixed.sort.join('|');
say '  sortuk      : ', sortuk(@mixed).join('|');
say '';
say 'the return type is ', sortuk(@words).WHAT.^name, ', and the input array';
say 'is copied — your own list is untouched.';

# Output:
#     plain .sort : абрикос банан евкаліпт ежак зебра яблуко іній їжак ґанок
#     sortuk      : абрикос банан ґанок евкаліпт ежак зебра іній їжак яблуко
#     
#     and it folds case, which plain .sort does not:
#       plain .sort : Банан|Яблуко|абрикос
#       sortuk      : абрикос|Банан|Яблуко
#     
#     the return type is List, and the input array
#     is copied — your own list is untouched.
