#!/usr/bin/env rakupp
# Algorithm::BinaryIndexedTree — The one thing to know
# https://raku.online/modules/algorithm-binaryindexedtree/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Algorithm::BinaryIndexedTree
#     rakupp 04-zero-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::BinaryIndexedTree;

my $t = Algorithm::BinaryIndexedTree.new(size => 8);
$t.add($_, 1) for 1 .. 8;

say 'eight buckets holding one each';
say '  sum(0)  : ', $t.sum(0);
say '  sum(1)  : ', $t.sum(1);
say '  sum(8)  : ', $t.sum(8);
say '';
$t.add(0, 1000);
say 'after add(0, 1000):';
say '  get(0)     : ', $t.get(0);
say '  sum(0)     : ', $t.sum(0);
say '  sum(1)     : ', $t.sum(1), '   but get(1) is still ', $t.get(1);
say '  sum(8)     : ', $t.sum(8);
say '  get(1..8)  : ', (1..8).map({ $t.get($_) }).join(' ');
say '';
say 'it does cancel in a range query:';
say '  sum(6) - sum(2) : ', $t.sum(6) - $t.sum(2);

# Output:
#     eight buckets holding one each
#       sum(0)  : 0
#       sum(1)  : 1
#       sum(8)  : 8
#     
#     after add(0, 1000):
#       get(0)     : 1000
#       sum(0)     : 1000
#       sum(1)     : 1001   but get(1) is still 1
#       sum(8)     : 1008
#       get(1..8)  : 1 1 1 1 1 1 1 1
#     
#     it does cancel in a range query:
#       sum(6) - sum(2) : 4
