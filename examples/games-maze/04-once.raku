#!/usr/bin/env rakupp
# Games::Maze — Carving happens exactly once
# https://raku.online/modules/games-maze/#carving-happens-exactly-once
#
# Install what it needs, then run it:
#     rakupp install Games::Maze
#     rakupp 04-once.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Games::Maze;

my $a = Games::Maze.new(height => 3, width => 3);
say 'render() with no make() first:';
say '  ', $_.raku for $a.render.chomp.lines;
say '  every interior character is a wall : ',
    $a.render.lines[1..*].join('').comb.grep({ $_ ne '_' && $_ ne '|' }).elems == 0;
say '';
my $b = Games::Maze.new(height => 4, width => 4);
my $first  = $b.make.render;
my $second = $b.make.render;
say 'a second make() changes nothing : ', $first eq $second;
say '';
my $c = Games::Maze.new(height => 3, width => 3);
$c.make(9, 9);
say 'make(9, 9) on a 3x3 grid does nothing, silently : ',
    $c.render.lines[1..*].join('').comb.grep({ $_ ne '_' && $_ ne '|' }).elems == 0;

# Output:
#     render() with no make() first:
#       " _ _ _ "
#       "|_|_|_|"
#       "|_|_|_|"
#       "|_|_|_|"
#       every interior character is a wall : True
#     
#     a second make() changes nothing : True
#     
#     make(9, 9) on a 3x3 grid does nothing, silently : True
