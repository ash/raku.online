#!/usr/bin/env rakupp
# Game::Sudoku — Reading a puzzle
# https://raku.online/modules/game-sudoku/#reading-a-puzzle
#
# Install what it needs, then run it:
#     rakupp install Game::Sudoku
#     rakupp 01-grid.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Game::Sudoku;

constant PUZZLE = '530070000600195000098000060800060003400803001700020006060000280000419005000080079';

my $g = Game::Sudoku.new(:code(PUZZLE));
say $g.gist;
say '';
say 'Str round-trips the code : ', $g.Str eq PUZZLE;
say 'valid                    : ', $g.valid;
say 'full                     : ', $g.full;
say 'complete                 : ', $g.complete;

# Output:
#     53 | 7 |   
#     6  |195|   
#      98|   | 6 
#     ---+---+---
#     8  | 6 |  3
#     4  |8 3|  1
#     7  | 2 |  6
#     ---+---+---
#      6 |   |28 
#        |419|  5
#        | 8 | 79
#     
#     Str round-trips the code : True
#     valid                    : True
#     full                     : False
#     complete                 : False
