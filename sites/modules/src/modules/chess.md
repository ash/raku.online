---
name: Chess
version: 0.2.4
auth: none stated
kind: Distribution · games
summary: Two chess notation grammars — a position in FEN and a game score in
  PGN — plus a terminal board printer in Unicode chess glyphs.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/?/Chess
source: git://github.com/grondilu/chess.git
---

## What it is for

Two text formats carry essentially all recorded chess. FEN describes a
position in one line; PGN describes a whole game. Reading either means a
grammar, and writing that grammar twice is what this distribution saves you.

There is no board representation here, no move generator and no legality
checking — the grammars recognise the notation and hand back a `Match`.

## Drawing a position

```raku name="show"
use Chess;

show-FEN($Chess::startpos //
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
```

```output
[30m[47m♜[100m♞[47m♝[100m♛[47m♚[100m♝[47m♞[100m♜[0m
[100m♟[47m♟[100m♟[47m♟[100m♟[47m♟[100m♟[47m♟[0m
[47m [100m [47m [100m [47m [100m [47m [100m [0m
[100m [47m [100m [47m [100m [47m [100m [47m [0m
[47m [100m [47m [100m [47m [100m [47m [100m [0m
[100m [47m [100m [47m [100m [47m [100m [47m [0m
[47m♙[100m♙[47m♙[100m♙[47m♙[100m♙[47m♙[100m♙[0m
[100m♖[47m♘[100m♗[47m♕[100m♔[47m♗[100m♘[47m♖[0m
```

`show-FEN` prints and returns `Nil`. There is no string-producing form, and
the ANSI escapes for the checkerboard are emitted unconditionally — redirect
its output to a file and the escapes go into the file.

## Reading a position

```raku name="fen"
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
```

```output
parsed         : True
active-color   : w
castling       : KQkq
en-passant     : -
half-move      : 0
full-move      : 1

and the constant the module ships:
  (Any)
```

## Reading a game

```raku name="pgn"
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
```

```output
parsed       : True
games        : 1
moves        : 3
move texts   : ("1. e4 e5", "2. Qh5 Nc6", "3. Qxf7#")
adjudication : 1-0

"1. e4 e5 2. Nf3"                        -> parses
"1. e8=Q Kh8 2. Qxh8# 1-0"               -> parses
"1. e4 \$1 \{best by test} e5 1/2-1/2"   -> parses
"1. e9 e5 1-0"                           -> no
"hello world"                            -> no
```

Tags, castling, promotion, numeric annotation glyphs, comments and all four
adjudications are handled, and the result is optional.

## The one thing to know

The `where Chess::FEN.parse($fen)` in `show-FEN`'s signature checks the
**shape** of the string, not the board. A rank that does not add up to eight
squares is "valid".

```raku name="shape-trap"
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
```

```output
"44444444/8/8/8/8/8/8/8 w - - 0 1"                               parses: True
"4/8/8/8/8/8/8/8 w - - 0 1"                                      parses: True
"8/8/8/8/8/8/8/8 w - - 0 1"                                      parses: True
"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq e3 99999 0"  parses: True

those are, in order: a rank of 32 squares, a rank of 4,
a board with no kings at all, and a five-digit half-move clock.
```

`token rank { <symbol> ** 1..8 }` counts **symbols**, never squares, so a rank
may describe anywhere from one to sixty-four of them. A parameter constraint
that runs a grammar reads like validation; here it is a spell-check.

A `Chess::FEN` match is not a validated position. If you need one, count the
squares yourself.

## Where the two engines differ

Nowhere. Every position, every game and every rejection in this page was
byte-identical on Raku++ and Rakudo, down to the ANSI escape bytes in the
board.

Two things worth knowing that are not engine differences. `show-FEN`'s body
depends on `$/` leaking out of its own **signature** — the `where` clause runs
the grammar and the body reads the match object it left behind — so the
parameter constraint is load-bearing and cannot be replaced with a cheaper
check. And the distribution declares **no `auth`**, which is why it has no
canonical raku.land path.
