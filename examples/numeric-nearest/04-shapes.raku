#!/usr/bin/env rakupp
# Numeric::Nearest — Two shapes to know
# https://raku.online/modules/numeric-nearest/#two-shapes-to-know
#
# Install what it needs, then run it:
#     rakupp install Numeric::Nearest
#     rakupp 04-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Numeric::Nearest;

say 'the list must be SORTED — nothing checks it, and an unsorted list';
say 'gives a silently wrong answer:';
say '  sorted   : ', nearestPair(15, (0, 10, 20, 30)).raku;
say '  unsorted : ', nearestPair(15, (30, 0, 20, 10)).raku;
say '';
say 'and the unit inside lib/Numeric/Nearest.pm6 is declared';
say '`unit module Nearest;` — so after `use Numeric::Nearest` the package';
say 'Numeric::Nearest does NOT exist and `Nearest` does:';
say '  ::("Numeric::Nearest").defined : ', ::('Numeric::Nearest').defined;
say '  ::("Nearest").defined          : ', ::('Nearest').defined;
say '';
say 'the two subs are exported, so you rarely need either name.';

# Output:
#     the list must be SORTED — nothing checks it, and an unsorted list
#     gives a silently wrong answer:
#       sorted   : 2 => 20
#       unsorted : 0 => 30
#     
#     and the unit inside lib/Numeric/Nearest.pm6 is declared
#     `unit module Nearest;` — so after `use Numeric::Nearest` the package
#     Numeric::Nearest does NOT exist and `Nearest` does:
#       ::("Numeric::Nearest").defined : False
#       ::("Nearest").defined          : False
#     
#     the two subs are exported, so you rarely need either name.
