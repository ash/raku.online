---
name: Game::Sudoku
version: 1.1.4
auth: zef:Scimon
kind: Distribution · games
summary: A 9x9 grid held as an 81-character string, answering validity,
  completeness and per-cell candidates, with a separate solver unit.
status: full
suite: 5 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:Scimon/Game::Sudoku
source: https://github.com/Scimon/p6-Game-Sudoku.git
---

## What it is for

A Sudoku grid is a small constraint problem, and the useful operations on it
are always the same: is this arrangement legal, is it finished, and what could
still go in this cell. Everything else — solving, generating, rating — is built
on those three.

This distribution provides them, plus a solver in its own unit so you can use
the grid without it.

## Reading a puzzle

```raku name="grid"
use Game::Sudoku;

constant PUZZLE = '530070000600195000098000060800060003400803001700020006060000280000419005000080079';

my $g = Game::Sudoku.new(:code(PUZZLE));
say $g.gist;
say '';
say 'Str round-trips the code : ', $g.Str eq PUZZLE;
say 'valid                    : ', $g.valid;
say 'full                     : ', $g.full;
say 'complete                 : ', $g.complete;
```

```output
53 | 7 |   
6  |195|   
 98|   | 6 
---+---+---
8  | 6 |  3
4  |8 3|  1
7  | 2 |  6
---+---+---
 6 |   |28 
   |419|  5
   | 8 | 79

Str round-trips the code : True
valid                    : True
full                     : False
complete                 : False
```

`valid` says no row, column or box repeats a digit; `full` says there are no
blanks; `complete` is both. Note that `valid` on an **empty** grid is `True` —
there is nothing to conflict — so `valid` alone never means "this is a
puzzle".

## Candidates and coordinates

```raku name="cells"
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
```

```output
cell(0,0), a given 5 : 5
cell(2,0), a blank   : Nil
possible(2,0)        : (1, 2, 4)
possible(2,0,:set)   : (1, 2, 4)

row(0)    : (0,0) (1,0) (2,0) (3,0) (4,0) (5,0) (6,0) (7,0) (8,0)
square(4) : (3,3) (3,4) (3,5) (4,3) (4,4) (4,5) (5,3) (5,4) (5,5)
```

`row`, `col` and `square` return lists of **`(x, y)` coordinates**, not cell
values. Reading them as values is a silent misuse that will look almost right.

`possible` on an already-filled cell returns an **empty list** — indistinguishable
from "this blank cell has no candidates", which is the interesting case.

## Solving

```raku name="solve"
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
```

```output
returns a : Game::Sudoku
a NEW object, not the one passed in : True
complete  : True
solution  : 534678912672195348198342567859761423426853791713924856961537284287419635345286179

the original is untouched : True
```

`solve-puzzle` applies naked and hidden singles until they run out, then
searches. It returns a new object and leaves yours alone — and it returns the
**partially** solved grid when it gives up rather than signalling failure, so
always test `.complete` on the result.

## The one thing to know

`cell($x, $y, $value)` silently refuses to change a cell that came from the
original clues, and still returns the game so the chain reads as if it worked.

```raku name="given-trap"
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
```

```output
cell(0,0) is a given, currently 5
  the setter returned the game itself : True
  cell(0,0) afterwards                : 5
  the code changed                    : False

a blank cell accepts a write:
  cell(2,0) : 4
and a cell you wrote yourself is NOT protected:
  cell(2,0) after a second write : 1
```

The setter's first statement is `return self if $!initial{…}`, so the return
value is `self` whether or not the write happened. `$g.cell(0,0,9).cell(1,1,2)`
chains happily past a refused write, and nothing in the interface tells you
which cells are protected.

Note the asymmetry too: only clues from `new` or `reset` are protected, and a
value you wrote yourself can be overwritten freely.

## Where the two engines differ

Only on `reset()` called with no `:code`, which is a silent no-op returning an
empty list on Raku++ and a binding failure on Rakudo. Every other spike in
this page — the grid, the candidates, the solve, the refused write — was
byte-identical.

One thing that is not an engine difference and will catch a port: `GridCode`
is exactly 81 characters of `0`–`9`, so the widespread convention of `.` for a
blank is rejected with `X::Multi::NoMatch` — an error that names nothing
useful. Translate dots to zeros before constructing.

Rakudo also prints a deprecation report at exit on any solve, because the
solver calls `.perl` internally on every iteration.
