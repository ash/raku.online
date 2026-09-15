---
name: Text::Chart
version: 0.0.3
auth: zef:JJMERELO
kind: Distribution · text output
summary: One function draws a vertical bar chart into a string — no axis, no
  labels, no scaling, and a layout that assumes one grapheme is one column.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: GPL-3.0
depends: none beyond the core
raku-land: https://raku.land/zef:JJMERELO/Text::Chart
source: git://github.com/JJ/p6-text-chart.git
---

## What it is for

Sometimes a terminal program wants to show the shape of a handful of numbers
and a plotting library is far too much machinery. `Text::Chart` draws the
smallest useful thing: `$max` rows of text, one column per data point, each
cell either the chart character or a space.

There is no axis, no label, no legend and no auto-scaling. What you get back
is a plain `Str` with `\n` between rows.

## Drawing a chart

```raku name="vertical"
use Text::Chart;

say 'vertical(max => 3, 1, 2, 3):';
print vertical(max => 3, 1, 2, 3);
say '';
say 'values above max are clipped, values at or below 0 draw nothing:';
print vertical(max => 3, 0, 3, 5);
```

```output
vertical(max => 3, 1, 2, 3):
  █
 ██
███

values above max are clipped, values at or below 0 draw nothing:
 ██
 ██
 ██
```

`:chart-chars` indexes by **column**, not by level — so it colours vertical
stripes, not horizontal bands:

```raku name="chars"
use Text::Chart;

say 'three columns, three characters:';
print vertical(max => 2, :chart-chars<abc>, 2, 2, 2);
say '';
say 'the exported default:';
say '  $default-char = ', $default-char, '  (U+', $default-char.ord.base(16), ')';
```

```output
three columns, three characters:
abc
abc

the exported default:
  $default-char = █  (U+2588)
```

## What comes back

Every row is right-padded to the full width, so the result always carries
trailing whitespace — and the result is not always a `Str`:

```raku name="shapes"
use Text::Chart;

sub describe($label, $v) {
    say sprintf('%-22s %-8s %s', $label, $v.WHAT.^name,
                $v.defined ?? $v.raku !! '(undefined)');
}

describe('max => 2, 1, 2',   vertical(max => 2, 1, 2));
describe('max => 2, no data', vertical(max => 2));
describe('max => 0, 1, 2',   vertical(max => 0, 1, 2));
```

```output
max => 2, 1, 2         Str      " █\n██\n"
max => 2, no data      Str      "\n\n"
max => 0, 1, 2         Any      (undefined)
```

`vertical(max => 0, …)` returns `Any`. The `$max^...0` sequence is empty, so
the accumulator is never assigned and there is no `Str` return constraint to
catch it. `.chars` on that result dies.

## The one thing to know

The chart lays out by grapheme, and `.chars` will tell you every row is the
same width. On a terminal they are not, unless your chart character is one
column wide.

```raku name="width"
use Text::Chart;

for '#', "\c[CHRISTMAS TREE]" -> $c {
    my $chart = vertical(max => 2, :chart-chars($c), 1, 2, 2);
    say $c eq '#' ?? '=== ASCII: cells line up ===' !! '=== emoji: same .chars, ragged ===';
    for $chart.lines -> $row {
        my $cols = [+] $row.comb.map({ .uniprop('East_Asian_Width') eq 'W'|'F' ?? 2 !! 1 });
        say sprintf('|%s|  .chars=%d  terminal-columns=%d', $row, $row.chars, $cols);
    }
    say '';
}
```

```output
=== ASCII: cells line up ===
| ##|  .chars=3  terminal-columns=3
|###|  .chars=3  terminal-columns=3

=== emoji: same .chars, ragged ===
| 🎄🎄|  .chars=3  terminal-columns=5
|🎄🎄🎄|  .chars=3  terminal-columns=6
```

A filled cell is one `.comb` grapheme; an empty cell is one ASCII space. If
the chart character is East-Asian wide, a row with gaps is narrower on screen
than a full row — while `.chars` reports both as equal. The module's own tags
advertise emoji and its shipped binary defaults to `⬜`, so the advertised use
is precisely the broken one.

## Where the two engines differ

A non-numeric data point is compared with numeric `>`. Rakudo's `Failure` from
`Str` numification is false in boolean context, so the point is treated as
"below every row" and the chart is drawn; Raku++ throws
`Cannot convert string to number` instead.

```raku name="nonnumeric"
use Text::Chart;

my @mixed = 1, 'x', 2;
say 'raw data          : ', @mixed.raku;
say 'a chart of it is engine-dependent, so filter first:';
my @clean = @mixed.grep({ .Str ~~ /^ '-'? \d+ ['.' \d+]? $/ })>>.Numeric;
say '  numeric entries : ', @clean.raku;
print vertical(max => 2, |@clean);
```

```output
raw data          : [1, "x", 2]
a chart of it is engine-dependent, so filter first:
  numeric entries : [1, 2]
 █
██
```

Two smaller divergences to keep out of any example. `.pick(-1)` returns an
empty sequence under Raku++ and throws `Coercion to UInt out of range` under
Rakudo, which is reachable here through a negative `max`. And the `*@data`
slurpy sits *after* the named parameters, so `vertical(3, 1, 2)` silently
treats the `3` as data on both engines — the shipped `raku-text-chart` binary
spells the option `--a-max`, not `--max`, for the same reason.
