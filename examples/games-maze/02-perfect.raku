#!/usr/bin/env rakupp
# Games::Maze — Is it a real maze?
# https://raku.online/modules/games-maze/#is-it-a-real-maze
#
# Install what it needs, then run it:
#     rakupp install Games::Maze
#     rakupp 02-perfect.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Games::Maze;

my ($h, $w) = 7, 9;
my @passages;
for ^20 {
    my $maze = Games::Maze.new(height => $h, width => $w);
    $maze.make;
    my @body = $maze.render.lines[1..*];
    # every space in the body is one opened wall, i.e. one passage
    @passages.push: @body.map({ $_.substr(1).comb.grep(' ').elems }).sum;
}

say "20 mazes of {$h}x{$w} = {$h * $w} cells";
say '  distinct passage counts : ', @passages.unique.sort.List.raku;
say '  a perfect maze needs    : ', $h * $w - 1, ' passages';
say '  every maze is perfect   : ', ?all(@passages.map(* == $h * $w - 1));
say '';
my $distinct = (^20).map({
    my $x = Games::Maze.new(height => $h, width => $w); $x.make; $x.render
}).unique.elems;
say '  distinct mazes from 20 fresh objects : ', $distinct;

# Output:
#     20 mazes of 7x9 = 63 cells
#       distinct passage counts : (62,)
#       a perfect maze needs    : 62 passages
#       every maze is perfect   : True
#     
#       distinct mazes from 20 fresh objects : 20
