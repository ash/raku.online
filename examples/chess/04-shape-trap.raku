#!/usr/bin/env rakupp
# Chess — The one thing to know
# https://raku.online/modules/chess/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Chess
#     rakupp 04-shape-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Chess::FEN;

for '44444444/8/8/8/8/8/8/8 w - - 0 1',
    '4/8/8/8/8/8/8/8 w - - 0 1',
    '8/8/8/8/8/8/8/8 w - - 0 1',
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq e3 99999 0' -> $fen {
    say sprintf('%-64s parses: %s', $fen.raku, ?Chess::FEN.parse($fen));
}
say '';
say 'those are, in order: a rank of 32 squares, a rank of 4,';
say 'a board with no kings at all, and a five-digit half-move clock.';

# Output:
#     "44444444/8/8/8/8/8/8/8 w - - 0 1"                               parses: True
#     "4/8/8/8/8/8/8/8 w - - 0 1"                                      parses: True
#     "8/8/8/8/8/8/8/8 w - - 0 1"                                      parses: True
#     "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq e3 99999 0"  parses: True
#     
#     those are, in order: a rank of 32 squares, a rank of 4,
#     a board with no kings at all, and a five-digit half-move clock.
