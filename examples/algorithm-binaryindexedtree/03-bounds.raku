#!/usr/bin/env rakupp
# Algorithm::BinaryIndexedTree — The bounds
# https://raku.online/modules/algorithm-binaryindexedtree/#the-bounds
#
# Install what it needs, then run it:
#     rakupp install Algorithm::BinaryIndexedTree
#     rakupp 03-bounds.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::BinaryIndexedTree;

my $t = Algorithm::BinaryIndexedTree.new(size => 8);

for 8, 9, -1 -> $i {
    my $r = try $t.sum($i);
    say sprintf('sum(%2d) -> %s', $i, $! ?? $!.message !! $r.Str);
}
say '';
say 'note that index == size is accepted, so new(size => 8) has NINE slots';
say 'the default new() allocates 1001 of them';

# Output:
#     sum( 8) -> 0
#     sum( 9) -> Error: index must be smaller than table size
#     sum(-1) -> Error: index must be larger or equal to 0
#     
#     note that index == size is accepted, so new(size => 8) has NINE slots
#     the default new() allocates 1001 of them
