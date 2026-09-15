---
name: String::Fold
version: 0.2.0
auth: none stated
kind: Distribution · text formatting
summary: Re-flow a string into lines no wider than a given width, splitting on
  whitespace and greedily refilling — a reflow rather than a wrap, since every
  existing break is discarded.
status: full
suite: 2 files, green
tested: 2026-09-15
license: AGPL-3.0
depends: none beyond the core
raku-land: https://raku.land/?/String::Fold
source: https://gitlab.com/tyil/perl6-string-fold
---

## What it is for

Long prose arriving from a database column, a command-line argument or an API
response has no line breaks in it, and printing it to a terminal gives you one
very long line. This distribution is the one sub that fixes that: split on
whitespace, refill greedily to a width, join with newlines.

It is deliberately small. There is no hyphenation, no justification, no
indent parameter and no handling of pre-formatted text.

## Folding a paragraph

```raku name="fold"
use String::Fold;

my $text = 'the quick brown fox jumps over the lazy dog';

for 10, 20, 43 -> $w {
    say "--- width $w";
    say fold($text, :width($w));
}
say '--- default width is 79';
say fold($text).lines.elems, ' line(s)';
```

```output
--- width 10
the quick
brown fox
jumps over
the lazy
dog
--- width 20
the quick brown fox
jumps over the lazy
dog
--- width 43
the quick brown fox jumps over the lazy dog
--- default width is 79
1 line(s)
```

The default is 79, the traditional terminal width less one. Anything wider
than the text itself gives you the text back on a single line.

## What it does to whitespace you already had

```raku name="whitespace"
use String::Fold;

sub show($label, $in, $w) {
    say sprintf('%-18s -> %s', $label, fold($in, :width($w)).subst("\n", '|', :g).raku);
}

show 'multiple spaces', 'a     b',           10;
show 'a tab',           "a\tb",              10;
show 'leading space',   '  hi there',        10;
show 'embedded newline', "alpha\nbeta gamma", 8;
show 'empty string',    '',                  10;
show 'spaces only',     '     ',             10;
```

```output
multiple spaces    -> "a b"
a tab              -> "a b"
leading space      -> "hi there"
embedded newline   -> "alpha|beta|gamma"
empty string       -> ""
spaces only        -> ""
```

Runs of spaces collapse to one, tabs become single spaces, leading whitespace
is dropped, and a newline you put in the input is treated as just more
whitespace to split on. That last one is the important one: this is a
**reflow**, not a wrapper. Feed it a poem or a pre-formatted address block and
the original line structure is gone.

## The one thing to know

A word longer than the width produces a spurious empty first line.

```raku name="longword"
use String::Fold;

my $r = fold('supercalifragilistic', :width(8));
say 'lines       : ', $r.lines.elems;
say 'first line  : ', $r.lines[0].raku;
say 'second line : ', $r.lines[1].raku;
say '';
say 'and the same for any text whose FIRST word overflows:';
say fold('hello world', :width(1)).lines.map(*.raku).join(' ');
```

```output
lines       : 2
first line  : ""
second line : "supercalifragilistic"

and the same for any text whose FIRST word overflows:
"" "hello" "world"
```

The function neither breaks the long word — which is a defensible choice — nor
refrains from emitting a blank line before it, which is not. `.lines[0]` is the
empty string. Code that prints the result of folding a single long token, a
URL say, gets a blank line it never asked for and never sees in testing until
a token happens to exceed the width.

Guard it by dropping a leading empty line, or check `.chars` against the width
before calling.

## Where the two engines differ

Only on stderr. For the long-word, empty-string and whitespace-only cases,
Rakudo emits `Use of uninitialized value of type Any in string context` — three
of them — from line 33 of the module, and Raku++ stays silent. The returned
strings are byte-identical on both engines in every case tested here.

`:width(0)` and negative widths are rejected by the parameter's `where`
constraint on both engines, arriving as an `X::TypeCheck::Binding::Parameter`
rather than a message that mentions widths.

Width is counted in graphemes, so a combining acute measures the same as a
precomposed one — correct — while CJK text at `:width(5)` is allowed five
characters that paint ten terminal columns.
