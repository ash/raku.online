#!/usr/bin/env rakupp
# Chess — Reading a game
# https://raku.online/modules/chess/#reading-a-game
#
# Install what it needs, then run it:
#     rakupp install Chess
#     rakupp 03-pgn.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Chess::PGN;

my $game = '1. e4 e5 2. Qh5 Nc6 3. Qxf7# 1-0';
my $m = Chess::PGN.parse($game);
say 'parsed       : ', ?$m;
say 'games        : ', $m<game>.elems;
say 'moves        : ', $m<game>[0]<move>.elems;
say 'move texts   : ', $m<game>[0]<move>.map(*.Str.trim).List.raku;
say 'adjudication : ', ~$m<game>[0]<adjudication>;
say '';
for '1. e4 e5 2. Nf3',
    '1. e8=Q Kh8 2. Qxh8# 1-0',
    '1. e4 $1 {best by test} e5 1/2-1/2',
    '1. e9 e5 1-0',
    'hello world' -> $s {
    say sprintf('%-40s -> %s', $s.raku, Chess::PGN.parse($s) ?? 'parses' !! 'no');
}

# Output:
#     parsed       : True
#     games        : 1
#     moves        : 3
#     move texts   : ("1. e4 e5", "2. Qh5 Nc6", "3. Qxf7#")
#     adjudication : 1-0
#     
#     "1. e4 e5 2. Nf3"                        -> parses
#     "1. e8=Q Kh8 2. Qxh8# 1-0"               -> parses
#     "1. e4 \$1 \{best by test} e5 1/2-1/2"   -> parses
#     "1. e9 e5 1-0"                           -> no
#     "hello world"                            -> no
