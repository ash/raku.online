#!/usr/bin/env rakupp
# Data::Tree — Where the two engines differ
# https://raku.online/modules/data-tree/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Data::Tree
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Tree;

my $t = lol2tree([1, [2, [4, 5]], [3, [6]]]);
say 'flatten is identical on both engines : ', flatten($t).raku;
say 'foldTree likewise                    : ',
    foldTree(-> $d, @k { $d + @k.sum }, $t);
say 'drawTree likewise.';
say '';
say 'levels and grep are not. Write them yourself:';
sub tiers($t) {
    my @out; my @cur = ($t,);
    while @cur { @out.push([@cur.map(*.data)]); @cur = @cur.map({ |$_.children }).Array }
    @out
}
sub prune($t, &keep) {
    return Nil unless keep($t);
    RTree.new(data => $t.data, children => $t.children.map({ prune($_, &keep) }).grep(*.defined))
}
say '  tiers : ', tiers($t).raku;
say '  prune : ', flatten(prune($t, { .data != 2 })).raku;

# Output:
#     flatten is identical on both engines : [1, 2, 4, 5, 3, 6]
#     foldTree likewise                    : 21
#     drawTree likewise.
#     
#     levels and grep are not. Write them yourself:
#       tiers : [[1], [2, 3], [4, 6], [5]]
#       prune : [1, 3, 6]
