#!/usr/bin/env rakupp
# Algorithm::BinaryIndexedTree — Building and querying
# https://raku.online/modules/algorithm-binaryindexedtree/#building-and-querying
#
# Install what it needs, then run it:
#     rakupp install Algorithm::BinaryIndexedTree
#     rakupp 01-fenwick.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::BinaryIndexedTree;

my $t = Algorithm::BinaryIndexedTree.new(size => 8);
my @freq = 0, 3, 1, 4, 1, 5, 9, 2, 6;     # index 0 unused for now
$t.add($_, @freq[$_]) for 1 .. 8;

say 'get  1..8 : ', (1..8).map({ $t.get($_) }).join(' ');
say 'sum  1..8 : ', (1..8).map({ $t.sum($_) }).join(' ');
say 'reference : ', [\+](@freq[1..8]).join(' ');
say '';
say 'a range query, sum(3..6) : ', $t.sum(6) - $t.sum(2);
say 'which should be          : ', @freq[3..6].sum;

# Output:
#     get  1..8 : 3 1 4 1 5 9 2 6
#     sum  1..8 : 3 4 8 9 14 23 25 31
#     reference : 3 4 8 9 14 23 25 31
#     
#     a range query, sum(3..6) : 19
#     which should be          : 19
