#!/usr/bin/env rakupp
# Data::Tree — Building and walking
# https://raku.online/modules/data-tree/#building-and-walking
#
# Install what it needs, then run it:
#     rakupp install Data::Tree
#     rakupp 02-unfold.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Tree;

my $t = unfoldTree(-> $n { ($n, $n < 4 ?? ($n * 2, $n * 2 + 1) !! ()) }, 1);
say 'unfoldTree from 1, branching while n < 4:';
print drawTree($t);
say '';
say 'the two collections map and grep:';
say '  doubled : ', flatten($t.map(* * 10)).raku;
say '';
my $f = unfoldForest(-> $n { ($n, ()) }, [7, 8, 9]);
say 'a Forest of three singletons : ', $f.trees.map(*.data).join(', ');
print drawForest($f);

# Output:
#     unfoldTree from 1, branching while n < 4:
#     1
#     |
#     +-2
#     | |
#     | +-4
#     | |
#     | `-5
#     |
#     `-3
#       |
#       +-6
#       |
#       `-7
#     the two collections map and grep:
#       doubled : [10, 20, 40, 50, 30, 60, 70]
#     
#     a Forest of three singletons : 7, 8, 9
#     7
#     
#     8
#     
#     9
