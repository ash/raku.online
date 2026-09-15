---
name: Highlight::Terminal
version: 0.0.2
auth: zef:FCO
kind: Distribution · terminal
summary: A lookup table from Raku syntax-category names to SGR colour
  parameters, plus the two methods that wrap text in the matching escape.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:FCO/Highlight::Terminal
source: https://github.com/FCO/Highlight-Terminal.git
---

## What it is for

If you are writing something that prints Raku source — a REPL, a
pretty-printer, a grammar tracer — you need a colour for each kind of token,
and picking ninety of them is not the interesting part of the job. This
distribution has picked them: a table from category name to SGR parameters,
and a method that wraps a string in the right escape.

It is a **role**, not a set of subs. You compose it into your own class.

## Composing and colouring

```raku name="hl"
use Highlight::Terminal;

class HL does Highlight::Terminal {}
my $h = HL.new;

say 'table entries       : ', $h.map.elems;
say 'entries with colour : ', $h.map.values.grep(*.defined).elems;
say '';
for <version arrow block multi> -> $t {
    say sprintf('%-8s %s', $t, $h.hl($t, 'TEXT').raku);
}
say 'unknown category    : ', $h.hl('no-such-category', 'TEXT').raku;
```

```output
table entries       : 90
entries with colour : 42

version  "\x[1B][33;4mTEXT\x[1B][m"
arrow    "\x[1B][35;1mTEXT\x[1B][m"
block    "\x[1B][35mTEXT\x[1B][m"
multi    "\x[1B][32;1mTEXT\x[1B][m"
unknown category    : "TEXT"
```

`use Highlight::Terminal;` on its own gives you nothing callable — no subs are
exported. Compose the role, then call `.hl($category, $text)`. An unknown
category passes its text through unchanged rather than erroring, which is
either convenient or a way to lose a typo silently.

## The fallback

```raku name="fallback"
use Highlight::Terminal;

class HL does Highlight::Terminal {}
my $h = HL.new;

for 'version', 'arrow', 'arrow-one', 'arrow-one-deeper', 'block-xxx', 'no-such' -> $t {
    say sprintf('from-map(%-20s) = %-8s   table entry: %s',
        "'$t'", $h.from-map($t).raku,
        $h.map{$t}:exists ?? $h.map{$t}.raku !! 'absent');
}
```

```output
from-map('version'           ) = "33;4"     table entry: "33;4"
from-map('arrow'             ) = "35;1"     table entry: "35;1"
from-map('arrow-one'         ) = "35;1"     table entry: Str
from-map('arrow-one-deeper'  ) = "35;1"     table entry: absent
from-map('block-xxx'         ) = "35"       table entry: Str
from-map('no-such'           ) = Nil        table entry: absent
```

`from-map` splits the category on `-` and walks the cumulative prefixes
longest-first, so `arrow-one-deeper` — absent from the table entirely — still
resolves to `arrow`'s colour. That is what the 48 undefined `Str` placeholders
in the table are for: they exist to make the prefix walk stop in the right
place.

## The one thing to know

`hl` does not nest. Highlighting a span that already contains a highlighted
span emits two resets, and the inner one cancels the outer colour.

```raku name="nesting"
use Highlight::Terminal;

class HL does Highlight::Terminal {}
my $h = HL.new;

my $inner = $h.hl('version', 'INNER');
my $outer = $h.hl('block', "before{$inner}after");

say 'inner : ', $inner.raku;
say 'outer : ', $outer.raku;
say 'reset sequences in the outer string : ', +$outer.comb(/ \x1b '[m' /);
say 'the word "after" is preceded by a reset, so it renders with no colour';
```

```output
inner : "\x[1B][33;4mINNER\x[1B][m"
outer : "\x[1B][35mbefore\x[1B][33;4mINNER\x[1B][mafter\x[1B][m"
reset sequences in the outer string : 2
the word "after" is preceded by a reset, so it renders with no colour
```

There is nothing in the API to say "restore the enclosing colour" — the reset
is unconditional. Anyone composing nested categories, a string literal inside
a block say, gets silently mis-coloured output. Colour the innermost spans
only, or re-emit the outer escape yourself after each inner span.

## Where the two engines differ

Not in output. The one measurable difference is how often the `where`
constraints on the two `hl` candidates are evaluated: a single `hl` call
rebuilds the 90-entry table four times under Raku++ and three under Rakudo,
and for an unknown category three times against one. Nothing a user sees, but
it says something about the cost.

That cost is the thing worth knowing. `method map` constructs the whole
90-entry `Map` on **every call**, and every `hl` triggers it three or four
times. Highlighting a large file therefore pays for thousands of `Map`
constructions. Cache the table in your own class if you are colouring more
than a few lines.

Two smaller notes. The reset used is `ESC[m`, not the more usual `ESC[0m` —
equivalent per the specification, but it will surprise anyone string-matching
for `\e[0m`. And 48 of the 90 table entries are undefined `Str` type objects,
so `.map.values` is full of them.
