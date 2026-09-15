---
name: Terminal::Boxer
version: 0.3.1
auth: zef:thundergnat
kind: Distribution · text formatting
summary: Render a flat list of cells as a bordered grid in any of eleven
  line-drawing styles, plus a borderless one and a generic form that takes
  your own eleven glyphs.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:thundergnat/Terminal::Boxer
source: git://github.com/thundergnat/Terminal-Boxer.git
---

## What it is for

Printing a table to a terminal means choosing box-drawing characters and then
getting the corners right. This distribution has already made both decisions
eleven times over: single, double, rounded, heavy, ASCII, solid block, and
four mixed heavy-and-light combinations, each a sub taking the same arguments.

You hand it a flat list of cell values and say how many columns. It centres
each value and draws the frame.

## Drawing a grid

```raku name="grid"
use Terminal::Boxer;

my @cells = <id name qty 1 apple 7 2 pear 12>;

print ss-box(:col(3), @cells);
print ascii-box(:col(3), @cells);
print dd-box(:col(3), @cells);
```

```output
┌─────┬─────┬─────┐
│  id │ name│ qty │
├─────┼─────┼─────┤
│  1  │apple│  7  │
├─────┼─────┼─────┤
│  2  │ pear│  12 │
└─────┴─────┴─────┘
+-----+-----+-----+
|  id | name| qty |
+-----+-----+-----+
|  1  |apple|  7  |
+-----+-----+-----+
|  2  | pear|  12 |
+-----+-----+-----+
╔═════╦═════╦═════╗
║  id ║ name║ qty ║
╠═════╬═════╬═════╣
║  1  ║apple║  7  ║
╠═════╬═════╬═════╣
║  2  ║ pear║  12 ║
╚═════╩═════╩═════╝
```

The eleven style subs are `ss-box`, `ds-box`, `dd-box`, `sd-box`, `rs-box`,
`hs-box`, `hl-box`, `lh-box`, `ascii-box`, `block-box` and `no-box`. They take
the same named arguments and differ only in glyphs.

## The named arguments

```raku name="options"
use Terminal::Boxer;

print ss-box(:col(2), :cell(8), <alpha beta gamma delta>);
print ss-box(:col(2), :indent('>>>'), <ab cd ef gh>);
print ss-box(:col(2), :ch(2), <ab cd ef gh>);
print ss-box(:col(2), :f({ '[' ~ $^t ~ ']' }), <ab cd ef gh>);
print draw(:draw('=!/v\\>+<\\^/'), :col(2), :cw(3), :ch(1), <aa bb cc dd>);
```

```output
┌────────┬────────┐
│  alpha │  beta  │
├────────┼────────┤
│  gamma │  delta │
└────────┴────────┘
>>>┌──┬──┐
>>>│ab│cd│
>>>├──┼──┤
>>>│ef│gh│
>>>└──┴──┘
┌──┬──┐
│ab│cd│
│  │  │
├──┼──┤
│ef│gh│
│  │  │
└──┴──┘
┌──┬──┐
│[ab]│[cd]│
├──┼──┤
│[ef]│[gh]│
└──┴──┘
/===v===\
! aa! bb!
>===+===<
! cc! dd!
\===^===/
```

`:cell` (or `:cw`) sets the cell width, `:ch` the cell height in lines,
`:indent` a string prefixed to every output line, and `:f` a per-cell
formatter that receives the cell text and whose return value is used verbatim.
`draw` is the generic form: its `:draw` wants an **eleven-character glyph
string** — horizontal, vertical, top-left, top-tee, top-right, left-tee,
cross, right-tee, bottom-left, bottom-tee, bottom-right — not a style name.
Pass it the word `'ascii'` and it will cheerfully use those letters as box
glyphs.

## The one thing to know

`:cell` is a padding target, not a limit. Content wider than it is neither
truncated nor wrapped, and the border is still drawn at the width you asked
for, so the table visibly breaks.

```raku name="cell-trap"
use Terminal::Boxer;

print ss-box(:col(2), :cell(3), 'ok', 'a much longer value', 'x', 'y');
```

```output
┌───┬───┐
│ ok│a much longer value│
├───┼───┤
│ x │ y │
└───┴───┘
```

The horizontal rules are three wide while the first row carries a
nineteen-character cell, so the `│` separators no longer line up with the
`┬` and `┼` junctions on any row. There is no warning, no exception and no
`:truncate` option — and this is exactly the case `:cell` exists to handle.

Truncate the values yourself before handing them over.

## Where the two engines differ

On a mistake, and they disagree about how fatal it is. An array of arrays
never works — the `*@content` slurpy does not flatten elements that sit in
scalar containers, so each row arrives as one "cell" and `.chars` on it
returns a list, which is interpolated into a `sprintf` width. Raku++ emits
the invalid directive as literal text (`%2 4 3s`) and carries on; Rakudo
throws `Directive 2 4 3s is not valid in sprintf format`.

```raku name="aoa"
use Terminal::Boxer;

my @rows = ['id','name'], ['1','apple'];
print ss-box(:col(2), |@rows.map(*.Slip));
```

```output
┌─────┬─────┐
│  id │ name│
├─────┼─────┤
│  1  │apple│
└─────┴─────┘
```

Flatten with `|@rows.map(*.Slip)`, as above, or pass a flat list plus
`:col(n)`. The same divergence appears with a two-parameter `:f` callback:
Rakudo throws `Too few positionals passed`, Raku++ binds `Any` to the second
parameter and runs. `no-box` also makes Rakudo warn about an uninitialized
value on stderr where Raku++ is silent; the output is the same.

Three more things that are not engine differences. Cell width is one **global
maximum** across the whole table, not per column, so a single long value
widens every column. `:f` never receives the width and its return value is
inserted without padding, so it cannot change alignment. And widths are
counted in graphemes, so CJK and emoji overflow the frame.
