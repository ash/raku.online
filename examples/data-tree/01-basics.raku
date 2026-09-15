#!/usr/bin/env rakupp
# Data::Tree — Building and walking
# https://raku.online/modules/data-tree/#building-and-walking
#
# Install what it needs, then run it:
#     rakupp install Data::Tree
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Tree;

my $t = lol2tree([1, [2, [4, 5]], [3, [6]]]);
say 'data     : ', $t.data;
say 'children : ', $t.children.map(*.data).join(', ');
say '';
say 'flatten  : ', flatten($t).raku;
say 'foldTree : ', foldTree(-> $d, @kids { $d + @kids.sum }, $t);
say '  (levels is engine-dependent — see the last section)';
say '';
print drawTree($t);

# Output:
#     data     : 1
#     children : 2, 3
#     
#     flatten  : [1, 2, 4, 5, 3, 6]
#     foldTree : 21
#       (levels is engine-dependent — see the last section)
#     
#     1
#     |
#     +-2
#     | |
#     | `-4
#     |   |
#     |   `-5
#     |
#     `-3
#       |
#       `-6
