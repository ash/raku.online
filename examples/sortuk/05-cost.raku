#!/usr/bin/env rakupp
# sortuk — Where the two engines differ
# https://raku.online/modules/sortuk/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install sortuk
#     rakupp 05-cost.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use SortUk;

say 'the algorithm is an O(n²) bubble sort with an O(n) .comb inside the';
say 'comparison — it re-combs both words for every character comparison.';
say '';
my @words = (^40).map({ 'абвгґдеєжз'.comb.roll(6).join });
my $t = now;
my @sorted = sortuk(@words);
say '40 six-letter words sorted : ', @sorted.elems, ' back';
say '  in under a second        : ', (now - $t) < 1;
say '';
say 'fine for a menu or a glossary; not for a column of a database.';
say '';
say 'the shipped bin/sortuk takes the words as arguments, or one argument';
say 'that is an existing file, read line by line.';

# Output:
#     the algorithm is an O(n²) bubble sort with an O(n) .comb inside the
#     comparison — it re-combs both words for every character comparison.
#     
#     40 six-letter words sorted : 40 back
#       in under a second        : True
#     
#     fine for a menu or a glossary; not for a column of a database.
#     
#     the shipped bin/sortuk takes the words as arguments, or one argument
#     that is an existing file, read line by line.
