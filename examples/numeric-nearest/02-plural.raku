#!/usr/bin/env rakupp
# Numeric::Nearest — Many keys at once
# https://raku.online/modules/numeric-nearest/#many-keys-at-once
#
# Install what it needs, then run it:
#     rakupp install Numeric::Nearest
#     rakupp 02-plural.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Numeric::Nearest;

my @grid = 0, 10, 20, 30, 40;
say 'nearestPairs over ascending keys:';
say '  ', nearestPairs((0, 12, 19, 41), @grid).map(*.raku).join('  ');
say '';
say 'and over unsorted ones — it feeds each search the previous answer`s';
say 'index as a starting hint, so order affects the work but not the';
say 'answer:';
my @keys = 41, 0, 19, 12;
say '  ', nearestPairs(@keys, @grid).map(*.raku).join('  ');
say '';
say 'return type : ', nearestPairs((1,), @grid).WHAT.^name;

# Output:
#     nearestPairs over ascending keys:
#       0 => 0  1 => 10  2 => 20  4 => 40
#     
#     and over unsorted ones — it feeds each search the previous answer`s
#     index as a starting hint, so order affects the work but not the
#     answer:
#       4 => 40  0 => 0  2 => 20  1 => 10
#     
#     return type : Seq
