---
name: Text::BorderedBlock
version: 0.1.0
auth: none stated
kind: Distribution · text formatting
summary: Draw a heavy-ruled box around a block of text, with an optional
  header and footer, growing to fit the widest line but never below a
  configurable minimum.
status: full
suite: 1 file, green
tested: 2026-09-15
license: AGPL-3.0
depends: Terminal::ANSIColor
raku-land: https://raku.land/?/Text::BorderedBlock
source: none stated
---

## What it is for

A command-line program that wants to set something apart — a warning, a
summary, the licence text at the end of `--version` — reaches for a box. This
distribution draws one: heavy rules around the outside, lighter rules
separating an optional header and footer from the body, and a width that
adapts to the content without dropping below a floor you set.

The floor matters more than it sounds. Give several blocks the same
`minimum-width` and they line up, however different their contents.

## Boxing a block

```raku name="box"
use Text::BorderedBlock;

say Text::BorderedBlock.new(
    content       => "hello\nworld",
    minimum-width => 20,
).render;

say Text::BorderedBlock.new(
    content       => "the body of the block",
    header        => 'HEADING',
    footer        => 'a footnote',
    minimum-width => 30,
).render;
```

```output
┏━━━━━━━━━━━━━━━━━━━━┓
┃hello               ┃
┃world               ┃
┗━━━━━━━━━━━━━━━━━━━━┛
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃HEADING                       ┃
┠──────────────────────────────┨
┃the body of the block         ┃
┠──────────────────────────────┨
┃a footnote                    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

Everything is an attribute on the class, so the same object can be rendered
more than once, and `render` has a second candidate that takes the content
positionally and overrides the attributes for that call alone.

## How the width is chosen

```raku name="width"
use Text::BorderedBlock;

sub show($label, |c) {
    say "--- $label";
    say Text::BorderedBlock.new(|c).render;
}

show 'minimum wins',      content => 'hi', minimum-width => 14;
show 'content wins',      content => '0123456789ABCDEFGHIJ', minimum-width => 10;
show 'the header counts', content => 'hi', header => 'a rather long header', minimum-width => 5;
show 'empty content',     content => '', minimum-width => 8;
```

```output
--- minimum wins
┏━━━━━━━━━━━━━━┓
┃hi            ┃
┗━━━━━━━━━━━━━━┛
--- content wins
┏━━━━━━━━━━━━━━━━━━━━┓
┃0123456789ABCDEFGHIJ┃
┗━━━━━━━━━━━━━━━━━━━━┛
--- the header counts
┏━━━━━━━━━━━━━━━━━━━━┓
┃a rather long header┃
┠────────────────────┨
┃hi                  ┃
┗━━━━━━━━━━━━━━━━━━━━┛
--- empty content
┏━━━━━━━━┓
┗━━━━━━━━┛
```

`minimum-width` is a genuine minimum: content wider than it makes the box
grow, and the header participates in the measurement alongside the body.
Empty content produces a box with no interior row at all — not a blank one.

Note the default if you say nothing is **66**, so a two-word block renders 68
columns wide unless you set the floor yourself.

## The one thing to know

The width measurement goes to real trouble to discount ANSI escape sequences —
that is what the `Terminal::ANSIColor` dependency buys — and then counts an
East Asian ideograph as one column.

```raku name="width-trap"
use Text::BorderedBlock;

use Terminal::ANSIColor;
my $coloured = colored('red text', 'red');
say 'the coloured string is ', $coloured.chars, ' characters long';
say Text::BorderedBlock.new(content => $coloured, minimum-width => 12)
    .render.subst(/ \e '[' <[0..9;]>* 'm' /, '', :g);
say '';
my $cjk = "\c[CJK UNIFIED IDEOGRAPH-6F22]\c[CJK UNIFIED IDEOGRAPH-5B57]";
say Text::BorderedBlock.new(content => "abcd\n$cjk", minimum-width => 10).render;
```

```output
the coloured string is 17 characters long
┏━━━━━━━━━━━━┓
┃red text    ┃
┗━━━━━━━━━━━━┛

┏━━━━━━━━━━┓
┃abcd      ┃
┃漢字        ┃
┗━━━━━━━━━━┛
```

The coloured row is padded correctly: seventeen characters of string measured
as eight and padded to twelve. The ideograph row is padded to a nominal ten
and paints twelve columns, so its right-hand rule sits two columns past every
other one.

A module careful enough to strip colour codes is the last place anyone expects
naive `.chars` arithmetic, which is what makes this the easiest way to break
it. If the content can contain CJK or emoji, pad it yourself before handing it
over.

## Where the two engines differ

Only on stderr, and only when you supply a partial glyph set. Rakudo emits
`Use of uninitialized value %!box-characters{...}` warnings for each missing
key; Raku++ is silent. The rendered strings are identical.

Two things about `box-characters` that are not engine differences and will
cost you an afternoon. The hash **replaces** the defaults wholesale rather
than merging into them, so supplying one key erases the other ten and the box
loses its borders entirely. And the separator keys are spelled
**`seperator`**, `seperator-left` and `seperator-right`, with three e's;
spelling it correctly gives you a silently empty separator row.

The nine keys in full are `outer-top-left`, `outer-top-right`,
`outer-bottom-left`, `outer-bottom-right`, `outer-horizontal`,
`outer-vertical`, `seperator-left`, `seperator-right` and `seperator`. Supply
all nine or none.
