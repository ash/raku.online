#!/usr/bin/env rakupp
# Algorithm::SetUnion — Reading the components out
# https://raku.online/modules/algorithm-setunion/#reading-the-components-out
#
# Install what it needs, then run it:
#     rakupp install Algorithm::SetUnion
#     rakupp 02-components.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::SetUnion;

my $u = Algorithm::SetUnion.new(size => 8);
$u.union(0, 1); $u.union(2, 3); $u.union(1, 3); $u.union(4, 5);

my %g;
%g.push($u.find($_) => $_) for ^8;
for %g.keys.sort({ +$_ }) -> $r {
    say "root $r : ", %g{$r}.list.sort.join(','),
        "   nodes[$r].size = ", $u.nodes[$r].size;
}
say '';
say 'the size of the component holding 1 : ', $u.nodes[$u.find(1)].size;
say 'nodes[1].size, which is NOT that    : ', $u.nodes[1].size;

# Output:
#     root 0 : 0,1,2,3   nodes[0].size = 4
#     root 4 : 4,5   nodes[4].size = 2
#     root 6 : 6   nodes[6].size = 1
#     root 7 : 7   nodes[7].size = 1
#     
#     the size of the component holding 1 : 4
#     nodes[1].size, which is NOT that    : 1
