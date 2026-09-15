#!/usr/bin/env rakupp
# LCS::All — Recovering the elements
# https://raku.online/modules/lcs-all/#recovering-the-elements
#
# Install what it needs, then run it:
#     rakupp install LCS::All
#     rakupp 02-recover.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LCS::All;

my @x = <t h e   q u i c k>.grep(*.chars);
my @y = <t h e   q u a c k>.grep(*.chars);

my @r = allLCS(@x, @y);
say 'solutions : ', @r[0].elems;
for @r[0].list -> $s {
    say '  as indices  : ', $s.map({ "({.[0]},{.[1]})" }).join(' ');
    say '  as elements : ', $s.map({ @x[.[0]] }).join('');
}

# Output:
#     solutions : 1
#       as indices  : (0,0) (1,1) (2,2) (3,3) (4,4) (6,6) (7,7)
#       as elements : thequck
