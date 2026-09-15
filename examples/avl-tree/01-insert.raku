#!/usr/bin/env rakupp
# AVL-Tree — Building a tree
# https://raku.online/modules/avl-tree/#building-a-tree
#
# Install what it needs, then run it:
#     rakupp install AVL-Tree
#     rakupp 01-insert.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use AVL-Tree;

my $t = AVL-Tree.new;
$t.insert($_) for 5, 3, 8, 1, 4, 7, 9, 2, 6;

say 'keys, in order : ', $t.keys.join(' ');
say 'nodes          : ', $t.nodes.elems;
say 'root key       : ', $t.root.key;
say '';
print 'show-keys      : '; $t.show-keys;
print 'show-balances  : '; $t.show-balances;

# Output:
#     keys, in order : 1 2 3 4 5 6 7 8 9
#     nodes          : 9
#     root key       : 5
#     
#     show-keys      : 1 2 3 4 5 6 7 8 9 
#     show-balances  : 1 0 -1 0 0 0 -1 -1 0 
