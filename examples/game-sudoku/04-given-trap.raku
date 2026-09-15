#!/usr/bin/env rakupp
# Game::Sudoku — The one thing to know
# https://raku.online/modules/game-sudoku/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Game::Sudoku
#     rakupp 04-given-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Game::Sudoku;

constant PUZZLE = '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
my $g = Game::Sudoku.new(:code(PUZZLE));

say 'cell(0,0) is a given, currently ', $g.cell(0, 0);
my $ret = $g.cell(0, 0, 9);
say '  the setter returned the game itself : ', $ret === $g;
say '  cell(0,0) afterwards                : ', $g.cell(0, 0);
say '  the code changed                    : ', $g.Str ne PUZZLE;
say '';
say 'a blank cell accepts a write:';
$g.cell(2, 0, 4);
say '  cell(2,0) : ', $g.cell(2, 0);
say 'and a cell you wrote yourself is NOT protected:';
$g.cell(2, 0, 1);
say '  cell(2,0) after a second write : ', $g.cell(2, 0);

# Output:
#     cell(0,0) is a given, currently 5
#       the setter returned the game itself : True
#       cell(0,0) afterwards                : 5
#       the code changed                    : False
#     
#     a blank cell accepts a write:
#       cell(2,0) : 4
#     and a cell you wrote yourself is NOT protected:
#       cell(2,0) after a second write : 1
