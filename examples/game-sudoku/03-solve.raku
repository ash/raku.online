#!/usr/bin/env rakupp
# Game::Sudoku — Solving
# https://raku.online/modules/game-sudoku/#solving
#
# Install what it needs, then run it:
#     rakupp install Game::Sudoku
#     rakupp 03-solve.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Game::Sudoku;
use Game::Sudoku::Solver;

constant PUZZLE = '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
my $g = Game::Sudoku.new(:code(PUZZLE));

my $solved = solve-puzzle($g);
say 'returns a : ', $solved.^name;
say 'a NEW object, not the one passed in : ', !($solved === $g);
say 'complete  : ', $solved.complete;
say 'solution  : ', $solved.Str;
say '';
say 'the original is untouched : ', $g.Str eq PUZZLE;

# Output:
#     returns a : Game::Sudoku
#     a NEW object, not the one passed in : True
#     complete  : True
#     solution  : 534678912672195348198342567859761423426853791713924856961537284287419635345286179
#     
#     the original is untouched : True
