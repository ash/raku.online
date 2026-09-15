---
name: Automata::Cellular
version: 0.2.3
auth: zef:raku-community-modules
kind: Distribution · simulation
summary: Run Wolfram's elementary one-dimensional cellular automata — the 256
  three-neighbour rules — on a wrap-around row seeded with a single live cell.
status: full
suite: 2 files, green
tested: 2026-09-15
license: NOASSERTION
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Automata::Cellular
source: https://github.com/raku-community-modules/Automata-Cellular.git
---

## What it is for

Wolfram's elementary automata are the smallest interesting computational
systems there are: a row of cells, each updated from itself and its two
neighbours, which gives 256 possible rules. Rule 30 produces chaos good enough
that Mathematica used it as a random source; rule 110 is Turing-complete; rule
90 draws a Sierpiński triangle.

They are the standard demonstration of complexity from simple rules, and this
distribution runs them.

## Running a rule

```raku name="wolfram"
use Automata::Cellular;

my $w = Wolfram.new(number => 30, width => 21);
say 'generation 0: ', $w.current;
for 1 .. 6 {
    $w.succ;
    say "generation $_: ", $w.current;
}
```

```output
generation 0: ..........X..........
generation 1: .........XXX.........
generation 2: ........XX..X........
generation 3: .......XX.XXXX.......
generation 4: ......XX..X...X......
generation 5: .....XX.XXXX.XXX.....
generation 6: ....XX..X....X..X....
```

The row wraps around, and the seed is a single live cell in the middle. That
is not configurable — there is no way to set an arbitrary starting row.

## Other rules, other glyphs

```raku name="rules"
use Automata::Cellular;

for 90, 110, 184 -> $n {
    my $w = Wolfram.new(number => $n, width => 17);
    say "rule $n";
    for ^4 { say '  ', $w.current; $w.succ }
}
say '';
say 'custom glyphs : ', Wolfram.new(number => 90, width => 9, format => <_ #>).current;
```

```output
rule 90
  ........X........
  .......X.X.......
  ......X...X......
  .....X.X.X.X.....
rule 110
  ........X........
  .......XX........
  ......XXX........
  .....XX.X........
rule 184
  ........X........
  .........X.......
  ..........X......
  ...........X.....

custom glyphs : ____#____
```

Rule 90's Sierpiński triangle is visible in four generations.

## The rule table

```raku name="table"
use Automata::Cellular;

my $r = Rule.new(number => 30);
say $r.Str;
say 'Rule.Numeric    : ', $r.Numeric;
say 'Wolfram.Numeric : ', Wolfram.new(number => 110, width => 9).Numeric;
```

```output
Rule 30 subrules:
000 => 0
001 => 1
010 => 1
011 => 1
100 => 1
101 => 0
110 => 0
111 => 0

Rule.Numeric    : 30
Wolfram.Numeric : 110
```

`Rule` exposes the eight sub-rules — one per three-cell neighbourhood — which
is the whole content of a Wolfram number.

## The one thing to know

`use Automata::Cellular` gives you no such type. It injects **`Wolfram`** and
**`Rule`** into `GLOBAL`.

```raku name="global-trap"
use Automata::Cellular;

say 'the two names the module puts into GLOBAL:';
say '  Wolfram : ', ::('Wolfram').^name;
say '  Rule    : ', ::('Rule').^name;
say '';
say 'those are maximally generic names in the GLOBAL namespace.';
say 'declaring your own `class Rule` — the single most natural name';
say 'in a program about rule-based automata — collides with this one.';
```

```output
the two names the module puts into GLOBAL:
  Wolfram : Wolfram
  Rule    : Rule

those are maximally generic names in the GLOBAL namespace.
declaring your own `class Rule` — the single most natural name
in a program about rule-based automata — collides with this one.
```

The file carries no `unit` declaration, so its two package declarations land in
`GLOBAL`. Declaring your own `class Rule` is a hard compile error on Rakudo
(`Redeclaration of symbol 'Rule'`) and, on Raku++, compiles and then explodes
from **inside the module** with `No such method 'hash' for invocant of type
'Rule'` when the automaton next steps.

There is no way to scope the import. If you need a `Rule` of your own, put the
automaton in another compilation unit.

## Where the two engines differ

Only in how that collision breaks — a compile error on Rakudo, a runtime
failure from inside the module on Raku++ — and in whether `.^attributes`
lists role-composed attributes. Every generation, every rule and every glyph
was byte-identical.

Three things that are the same on both and will catch you.

**`$w++` destroys the object.** `succ` returns the mutated state array, and
`++` assigns that return value back over the variable — so after `$w++` your
variable holds an `Array[Int]` and `$w.current` is a method-not-found. Call
`.succ` as a statement.

**Rule numbers outside 0..255 are accepted in silence.** `number => 256`
produces the sub-rule table of rule 0, because the nine-character binary
formatting loses its leading bit in the zip against eight keys. There is no
range check.

**An even `width` is off by one**: the seed row has `width + 1` cells,
corrected only by the first `succ`. And `run()` prints via `say` and returns
`Any` — on the default width of 101 it emits fifty lines.
