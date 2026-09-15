#!/usr/bin/env rakupp
# Algorithm::BinaryIndexedTree — Updating
# https://raku.online/modules/algorithm-binaryindexedtree/#updating
#
# Install what it needs, then run it:
#     rakupp install Algorithm::BinaryIndexedTree
#     rakupp 02-update.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::BinaryIndexedTree;

my $t = Algorithm::BinaryIndexedTree.new(size => 8);
$t.add($_, 1) for 1 .. 8;

say 'before : get(5)=', $t.get(5), ' sum(8)=', $t.sum(8);
$t.add(5, 100);
say 'after add(5, 100) : get(5)=', $t.get(5), ' sum(8)=', $t.sum(8);
say '';
say 'add is an INCREMENT, not a store — there is no setter:';
$t.add(5, 100);
say 'after a second add(5, 100) : get(5)=', $t.get(5);

# Output:
#     before : get(5)=1 sum(8)=8
#     after add(5, 100) : get(5)=101 sum(8)=108
#     
#     add is an INCREMENT, not a store — there is no setter:
#     after a second add(5, 100) : get(5)=201
