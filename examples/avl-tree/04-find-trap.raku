#!/usr/bin/env rakupp
# AVL-Tree — The one thing to know
# https://raku.online/modules/avl-tree/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install AVL-Tree
#     rakupp 04-find-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use AVL-Tree;

my $t = AVL-Tree.new;
$t.insert($_) for 5, 3, 8, 1, 4, 7, 9, 2, 6;

say 'the tree holds : ', $t.keys.join(' ');
say '';
say 'key  present?  find() returns';
for 1 .. 10 -> $k {
    my $found = $t.find($k);
    say sprintf('%3d  %-9s  %s', $k,
        $t.keys.grep($k) ?? 'yes' !! 'no',
        $found ~~ AVL-Tree::Node ?? 'Node(key=' ~ $found.key ~ ')' !! 'Empty');
}
say '';
say 'the right spine from the root : ', gather {
    my $n = $t.root;
    while $n { take $n.key; $n = $n.right }
}.join(' ');

# Output:
#     the tree holds : 1 2 3 4 5 6 7 8 9
#     
#     key  present?  find() returns
#       1  yes        Empty
#       2  yes        Empty
#       3  yes        Empty
#       4  yes        Empty
#       5  yes        Node(key=5)
#       6  yes        Empty
#       7  yes        Empty
#       8  yes        Node(key=8)
#       9  yes        Node(key=9)
#      10  no         Empty
#     
#     the right spine from the root : 5 8 9
