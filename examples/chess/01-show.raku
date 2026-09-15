#!/usr/bin/env rakupp
# Chess — Drawing a position
# https://raku.online/modules/chess/#drawing-a-position
#
# Install what it needs, then run it:
#     rakupp install Chess
#     rakupp 01-show.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Chess;

show-FEN($Chess::startpos //
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');

# Output:
#     [30m[47m♜[100m♞[47m♝[100m♛[47m♚[100m♝[47m♞[100m♜[0m
#     [100m♟[47m♟[100m♟[47m♟[100m♟[47m♟[100m♟[47m♟[0m
#     [47m [100m [47m [100m [47m [100m [47m [100m [0m
#     [100m [47m [100m [47m [100m [47m [100m [47m [0m
#     [47m [100m [47m [100m [47m [100m [47m [100m [0m
#     [100m [47m [100m [47m [100m [47m [100m [47m [0m
#     [47m♙[100m♙[47m♙[100m♙[47m♙[100m♙[47m♙[100m♙[0m
#     [100m♖[47m♘[100m♗[47m♕[100m♔[47m♗[100m♘[47m♖[0m
