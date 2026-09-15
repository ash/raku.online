#!/usr/bin/env rakupp
# UK::Sort — Sorting
# https://raku.online/modules/uk-sort/#sorting
#
# Install what it needs, then run it:
#     rakupp install UK::Sort
#     rakupp 02-alphabet.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UK::Sort;

my @alphabet = 'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя'.comb;
my @shuffled = @alphabet.reverse;
say 'official order : ', @alphabet.join(' ');
say 'sortuk of it   : ', sortuk(@shuffled).join(' ');
say 'matches        : ', sortuk(@shuffled).join eq @alphabet.join;

# Output:
#     official order : а б в г ґ д е є ж з и і ї й к л м н о п р с т у ф х ц ч ш щ ь ю я
#     sortuk of it   : а б в г ґ д е є ж з и і ї й к л м н о п р с т у ф х ц ч ш щ ь ю я
#     matches        : True
