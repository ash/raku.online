#!/usr/bin/env rakupp
# Algorithm::SetUnion — Unioning and finding
# https://raku.online/modules/algorithm-setunion/#unioning-and-finding
#
# Install what it needs, then run it:
#     rakupp install Algorithm::SetUnion
#     rakupp 01-union.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::SetUnion;

my $u = Algorithm::SetUnion.new(size => 8);

say 'a fresh forest — every element is its own root:';
say '  find(i) for 0..7 : ', (^8).map({ $u.find($_) }).join(' ');
say '  .size            : ', $u.size, '   .nodes.elems : ', $u.nodes.elems;
say '';
say 'union(0,1) -> ', $u.union(0, 1);
say 'union(2,3) -> ', $u.union(2, 3);
say 'union(1,3) -> ', $u.union(1, 3);
say 'union(4,5) -> ', $u.union(4, 5);
say '  find(i) for 0..7 : ', (^8).map({ $u.find($_) }).join(' ');
say '';
say 'union of two elements already together -> ', $u.union(0, 3);
say 'union of an element with itself        -> ', $u.union(0, 0);

# Output:
#     a fresh forest — every element is its own root:
#       find(i) for 0..7 : 0 1 2 3 4 5 6 7
#       .size            : 8   .nodes.elems : 8
#     
#     union(0,1) -> True
#     union(2,3) -> True
#     union(1,3) -> True
#     union(4,5) -> True
#       find(i) for 0..7 : 0 0 0 0 4 4 6 7
#     
#     union of two elements already together -> False
#     union of an element with itself        -> False
