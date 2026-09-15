#!/usr/bin/env rakupp
# Games::Maze — Carving a maze
# https://raku.online/modules/games-maze/#carving-a-maze
#
# Install what it needs, then run it:
#     rakupp install Games::Maze
#     rakupp 01-maze.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Games::Maze;

my $m = Games::Maze.new(height => 6, width => 8);
$m.make;
my @lines = $m.render.lines;

say 'height / width        : ', $m.height, ' / ', $m.width;
say 'rendered lines        : ', @lines.elems, '  (one header plus height)';
say 'header                : ', @lines[0].raku;
say 'every row starts "|"  : ', ?all(@lines[1..*].map(*.starts-with('|')));
say 'every row is the same width : ', @lines[1..*].map(*.chars).unique.elems == 1;
say 'alphabet used         : ',
    $m.render.comb.unique.sort.map({ $_ eq "\n" ?? '\n' !! $_ }).join(' ');

# Output:
#     height / width        : 6 / 8
#     rendered lines        : 7  (one header plus height)
#     header                : " _ _ _ _ _ _ _ _ "
#     every row starts "|"  : True
#     every row is the same width : True
#     alphabet used         : \n   _ |
