---
name: Games::Maze
version: 0.0.1
auth: none stated
kind: Distribution · games
summary: Carve a rectangular maze by recursive backtracking and render it as
  ASCII, one header line plus one line per row.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/?/Games::Maze
source: https://github.com/manwar/Games-Maze.git
---

## What it is for

A maze is a spanning tree of a grid, and the shortest way to get one is
recursive backtracking: from a cell, shuffle the four directions, knock out
the wall to the first unvisited neighbour, recurse, and back up when you run
out. The result is a perfect maze — exactly one path between any two cells.

This distribution is that, plus an ASCII renderer.

## Carving a maze

The maze is random, so an example asserts the **properties** of one:

```raku name="maze"
use Games::Maze;

my $m = Games::Maze.new(height => 6, width => 8);
$m.make;
my @lines = $m.render.lines;

say 'height / width        : ', $m.height, ' / ', $m.width;
say 'rendered lines        : ', @lines.elems, '  (one header plus height)';
say 'header                : ', @lines[0].raku;
say 'every row starts "|"  : ', ?all(@lines[1..*].map(*.starts-with('|')));
say 'every row is the same width : ', @lines[1..*].map(*.chars).unique.elems == 1;
say 'alphabet used         : ',
    $m.render.comb.unique.sort.map({ $_ eq "\n" ?? '\n' !! $_ }).join(' ');
```

```output
height / width        : 6 / 8
rendered lines        : 7  (one header plus height)
header                : " _ _ _ _ _ _ _ _ "
every row starts "|"  : True
every row is the same width : True
alphabet used         : \n   _ |
```

`_` is a south wall, `|` an east wall. The renderer emits nothing else.

## Is it a real maze?

```raku name="perfect"
use Games::Maze;

my ($h, $w) = 7, 9;
my @passages;
for ^20 {
    my $maze = Games::Maze.new(height => $h, width => $w);
    $maze.make;
    my @body = $maze.render.lines[1..*];
    # every space in the body is one opened wall, i.e. one passage
    @passages.push: @body.map({ $_.substr(1).comb.grep(' ').elems }).sum;
}

say "20 mazes of {$h}x{$w} = {$h * $w} cells";
say '  distinct passage counts : ', @passages.unique.sort.List.raku;
say '  a perfect maze needs    : ', $h * $w - 1, ' passages';
say '  every maze is perfect   : ', ?all(@passages.map(* == $h * $w - 1));
say '';
my $distinct = (^20).map({
    my $x = Games::Maze.new(height => $h, width => $w); $x.make; $x.render
}).unique.elems;
say '  distinct mazes from 20 fresh objects : ', $distinct;
```

```output
20 mazes of 7x9 = 63 cells
  distinct passage counts : (62,)
  a perfect maze needs    : 62 passages
  every maze is perfect   : True

  distinct mazes from 20 fresh objects : 20
```

A spanning tree over *n* cells has exactly *n* − 1 edges, and every one of the
twenty has exactly that. The carving is correct.

## The one thing to know

The rendered maze is **completely sealed**. No entrance, no exit, nowhere to
start or finish.

```raku name="sealed"
use Games::Maze;

my ($h, $w) = 5, 6;
my $m = Games::Maze.new(height => $h, width => $w);
$m.make;
my @l = $m.render.lines;

sub south(Str $line) { (^$w).map({ $line.substr(1 + 2 * $_, 1) }) }
sub east(Str  $line) { (^$w).map({ $line.substr(2 + 2 * $_, 1) }) }

say 'bottom row: every south wall closed : ', ?all(south(@l[*-1]).map(* eq '_'));
say 'every row: right-hand east wall "|" : ', ?all(@l[1..*].map({ east($_)[*-1] eq '|' }));
say 'every row starts with "|"           : ', ?all(@l[1..*].map({ .substr(0,1) eq '|' }));
say 'header is all "_" separators        : ', @l[0] eq ' ' ~ ('_ ' x $w);
```

```output
bottom row: every south wall closed : True
every row: right-hand east wall "|" : True
every row starts with "|"           : True
header is all "_" separators        : True
```

It is a spanning tree drawn inside a closed box. Perfectly correct as a maze
in the graph sense, and unplayable as a puzzle — if you want one somebody can
walk through, you must open the border yourself.

## Carving happens exactly once

```raku name="once"
use Games::Maze;

my $a = Games::Maze.new(height => 3, width => 3);
say 'render() with no make() first:';
say '  ', $_.raku for $a.render.chomp.lines;
say '  every interior character is a wall : ',
    $a.render.lines[1..*].join('').comb.grep({ $_ ne '_' && $_ ne '|' }).elems == 0;
say '';
my $b = Games::Maze.new(height => 4, width => 4);
my $first  = $b.make.render;
my $second = $b.make.render;
say 'a second make() changes nothing : ', $first eq $second;
say '';
my $c = Games::Maze.new(height => 3, width => 3);
$c.make(9, 9);
say 'make(9, 9) on a 3x3 grid does nothing, silently : ',
    $c.render.lines[1..*].join('').comb.grep({ $_ ne '_' && $_ ne '|' }).elems == 0;
```

```output
render() with no make() first:
  " _ _ _ "
  "|_|_|_|"
  "|_|_|_|"
  "|_|_|_|"
  every interior character is a wall : True

a second make() changes nothing : True

make(9, 9) on a 3x3 grid does nothing, silently : True
```

`make` has no reset, so a second call finds every cell already visited and
returns immediately. `render` on an uncarved object is not an error — it draws
a solid lattice, which looks plausible at a glance. And an out-of-range
starting cell does nothing at all.

`for ^10 { say $maze.make.render }` therefore prints the same maze ten times.
To get a second maze you must construct a second object, which is what the
property spike above does.

## Where the two engines differ

Nowhere. Every property, every degenerate size, and the uncarved lattice
behaved identically on Raku++ and Rakudo — and ten thousand cells of unbounded
recursion completed on both without a stack problem.

`height => 0, width => 0` renders a single space rather than erroring, and the
distribution states no `auth`.
