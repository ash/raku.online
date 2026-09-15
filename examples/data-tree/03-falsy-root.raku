#!/usr/bin/env rakupp
# Data::Tree — The one thing to know
# https://raku.online/modules/data-tree/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Data::Tree
#     rakupp 03-falsy-root.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Tree;

for 0, '', False, 'x' -> $root {
    my $t = lol2tree([$root, ['kid']]);
    say sprintf('  root %-14s flatten %-22s levels %s',
                $root.raku, flatten($t).raku, levels($t).raku);
}
say '';
say 'the guard is  (! $t.data) && return [];  — so a tree of counters or';
say 'flags rooted at 0 silently has no levels.';
say '';
say 'build your own if the root can be falsy:';
sub tiers($t) {
    my @out;
    my @cur = ($t,);
    while @cur { @out.push([@cur.map(*.data)]); @cur = @cur.map({ |$_.children }).Array }
    @out
}
say '  tiers on a 0-rooted tree : ', tiers(lol2tree([0, ['kid']])).raku;

# Output:
#       root 0              flatten [0, "kid"]             levels []
#       root ""             flatten ["", "kid"]            levels []
#       root Bool::False    flatten [Bool::False, "kid"]   levels []
#       root "x"            flatten ["x", "kid"]           levels [["x"], ["kid"]]
#     
#     the guard is  (! $t.data) && return [];  — so a tree of counters or
#     flags rooted at 0 silently has no levels.
#     
#     build your own if the root can be falsy:
#       tiers on a 0-rooted tree : [[0], ["kid"]]
