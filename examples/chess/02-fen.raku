#!/usr/bin/env rakupp
# Chess — Reading a position
# https://raku.online/modules/chess/#reading-a-position
#
# Install what it needs, then run it:
#     rakupp install Chess
#     rakupp 02-fen.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Chess;
use Chess::FEN;

my $m = Chess::FEN.parse('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
say 'parsed         : ', ?$m;
say 'active-color   : ', ~$m<active-color>;
say 'castling       : ', ~$m<castling>;
say 'en-passant     : ', ~$m<en-passant>;
say 'half-move      : ', ~$m<half-move-clock>;
say 'full-move      : ', ~$m<full-move-number>;
say '';
say 'and the constant the module ships:';
say '  ', $Chess::startpos;

# Output:
#     parsed         : True
#     active-color   : w
#     castling       : KQkq
#     en-passant     : -
#     half-move      : 0
#     full-move      : 1
#     
#     and the constant the module ships:
#       (Any)
