#!/usr/bin/env rakupp
# Lingua::Conjunction — The one thing to know
# https://raku.online/modules/lingua-conjunction/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::Conjunction
#     rakupp 04-separator-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Conjunction;

say 'ordinary items  : ', conjunction(<toast jam tea>);
say 'one item has a comma in it:';
say '  ', conjunction('eggs, bacon', 'toast', 'jam');
say '';
say 'the alternate separator is ; by default, and :alt changes it:';
say '  ', conjunction('eggs, bacon', 'toast', 'jam', :alt(' / '));

# Output:
#     ordinary items  : toast, jam, and tea
#     one item has a comma in it:
#       eggs, bacon; toast; and jam
#     
#     the alternate separator is ; by default, and :alt changes it:
#       eggs, bacon /  toast /  and jam
