#!/usr/bin/env rakupp
# Game::Sudoku — Candidates and coordinates
# https://raku.online/modules/game-sudoku/#candidates-and-coordinates
#
# Install what it needs, then run it:
#     rakupp install Game::Sudoku
#     rakupp 02-cells.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Game::Sudoku;

constant PUZZLE = '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
my $g = Game::Sudoku.new(:code(PUZZLE));

say 'cell(0,0), a given 5 : ', $g.cell(0, 0).raku;
say 'cell(2,0), a blank   : ', $g.cell(2, 0).raku;
say 'possible(2,0)        : ', $g.possible(2, 0).List.raku;
say 'possible(2,0,:set)   : ', $g.possible(2, 0, :set).keys.sort.List.raku;
say '';
say 'row(0)    : ', $g.row(0).map({ '(' ~ .join(',') ~ ')' }).join(' ');
say 'square(4) : ', $g.square(4).map({ '(' ~ .join(',') ~ ')' }).join(' ');

# Output:
#     cell(0,0), a given 5 : 5
#     cell(2,0), a blank   : Nil
#     possible(2,0)        : (1, 2, 4)
#     possible(2,0,:set)   : (1, 2, 4)
#     
#     row(0)    : (0,0) (1,0) (2,0) (3,0) (4,0) (5,0) (6,0) (7,0) (8,0)
#     square(4) : (3,3) (3,4) (3,5) (4,3) (4,4) (4,5) (5,3) (5,4) (5,5)
