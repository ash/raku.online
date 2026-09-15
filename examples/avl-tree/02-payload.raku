#!/usr/bin/env rakupp
# AVL-Tree — Payloads and deletion
# https://raku.online/modules/avl-tree/#payloads-and-deletion
#
# Install what it needs, then run it:
#     rakupp install AVL-Tree
#     rakupp 02-payload.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use AVL-Tree;

my $t = AVL-Tree.new;
$t.insert($_, data => "d$_") for 5, 8, 9;
say 'find(8).data : ', $t.find(8).data;
say '';
my $d = AVL-Tree.new;
$d.insert($_) for 1 .. 9;
say 'before        : ', $d.keys.join(' ');
$d.delete(3);
say 'after del 3   : ', $d.keys.join(' ');
$d.delete(1, 9);
say 'after del 1,9 : ', $d.keys.join(' ');
$d.delete(42);
say 'after del 42  : ', $d.keys.join(' ');

# Output:
#     find(8).data : d8
#     
#     before        : 1 2 3 4 5 6 7 8 9
#     after del 3   : 1 2 4 5 6 7 8 9
#     after del 1,9 : 2 4 5 6 7 8
#     after del 42  : 2 4 5 6 7 8
