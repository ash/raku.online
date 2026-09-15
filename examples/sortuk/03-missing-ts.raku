#!/usr/bin/env rakupp
# sortuk — The one thing to know
# https://raku.online/modules/sortuk/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install sortuk
#     rakupp 03-missing-ts.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use SortUk;

say 'the module`s alphabet has 32 characters; Ukrainian has 33.';
say '';
for <цап іній>, <цукор ґанок>, <цвях їжак> -> @pair {
    say sprintf('  %-16s plain=%-16s sortuk=%s',
                @pair.join(','), @pair.sort.join(','), sortuk(@pair).join(','));
}
say '';
say 'і is the 12th letter and ц the 27th, yet цап sorts before іній.';
say 'ґ is the 5th, yet ґанок sorts after цукор. In every one of those';
say 'cases sortuk`s answer is byte-for-byte the plain .sort answer — the';
say 'module silently does nothing.';
say '';
say 'cmp_ch only consults the table when BOTH characters are in it;';
say 'otherwise it compares .ord. ц happens to sort correctly against х';
say 'and ч only because their codepoints run in the right order.';
say '';
say 'and sorting the whole alphabet in reverse DOES come back in order,';
say 'which is exactly why this hides:';
my @alphabet = 'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя'.comb;
say '  round trip holds : ', sortuk(@alphabet.reverse).join eq @alphabet.join;

# Output:
#     the module`s alphabet has 32 characters; Ukrainian has 33.
#     
#       цап,іній         plain=цап,іній         sortuk=цап,іній
#       цукор,ґанок      plain=цукор,ґанок      sortuk=цукор,ґанок
#       цвях,їжак        plain=цвях,їжак        sortuk=цвях,їжак
#     
#     і is the 12th letter and ц the 27th, yet цап sorts before іній.
#     ґ is the 5th, yet ґанок sorts after цукор. In every one of those
#     cases sortuk`s answer is byte-for-byte the plain .sort answer — the
#     module silently does nothing.
#     
#     cmp_ch only consults the table when BOTH characters are in it;
#     otherwise it compares .ord. ц happens to sort correctly against х
#     and ч only because their codepoints run in the right order.
#     
#     and sorting the whole alphabet in reverse DOES come back in order,
#     which is exactly why this hides:
#       round trip holds : True
