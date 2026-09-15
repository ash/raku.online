#!/usr/bin/env rakupp
# AVL-Tree — Return values
# https://raku.online/modules/avl-tree/#return-values
#
# Install what it needs, then run it:
#     rakupp install AVL-Tree
#     rakupp 03-returns.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use AVL-Tree;

my $t = AVL-Tree.new;
say 'the first insert into an empty tree returns a : ', $t.insert(10).^name;
say 'every insert after that returns a             : ', $t.insert(20).^name;
say 'an insert of a key already present            : ', $t.insert(10);
say 'an insert of a fresh key                      : ', $t.insert(30);

# Output:
#     the first insert into an empty tree returns a : AVL-Tree::Node
#     every insert after that returns a             : Bool
#     an insert of a key already present            : False
#     an insert of a fresh key                      : True
