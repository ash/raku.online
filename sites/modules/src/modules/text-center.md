---
name: Text::Center
version: 0.0.3
auth: zef:thundergnat
kind: Distribution · text formatting
summary: Centre a value in a field of a given width, padding both sides with
  a fill string — returning the text untouched rather than truncating when it
  will not fit.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:thundergnat/Text::Center
source: git://github.com/thundergnat/Text-Center.git
---

## What it is for

Raku gives you `.fmt('%20s')` for right alignment and `%-20s` for left, and
nothing at all for centring. This distribution is the missing third case: one
sub that puts a value in the middle of a field and fills the space on either
side.

The fill is a parameter, so the same call draws a centred heading, a rule with
a title in it, or a leader line in a table of contents.

## Centring something

```raku name="center"
use Text::Center;

say '[' ~ center('Raku', 20) ~ ']';
say '[' ~ center('odd', 10) ~ ']';
say '[' ~ center('even', 10) ~ ']';
say '[' ~ center(42, 9) ~ ']';
say '[' ~ center('', 6) ~ ']';
```

```output
[        Raku        ]
[    odd   ]
[   even   ]
[    42   ]
[      ]
```

The value is stringified, so a number needs no ceremony. An odd leftover goes
to the **left**: a two-character string in a nine-wide field gets three spaces
on the left and two on the right.

## Filling with something other than a space

```raku name="fill"
use Text::Center;

say center('Raku', 30, :fill('.'));
say center('Contents', 30, :fill('-'));
say center('', 12, :fill('='));
for 7, 8, 9, 10 -> $w {
    say sprintf('w=%2d [%s]', $w, center('ab', $w, :fill('#')));
}
```

```output
............ Raku ............
---------- Contents ----------
=====  =====
w= 7 [## ab #]
w= 8 [## ab ##]
w= 9 [### ab ##]
w=10 [### ab ###]
```

Note what happened to the dots: the text is not butted up against them. A
non-space fill gets an automatic space on each side of the value, and those
two spaces come out of the width budget. There is no way to switch it off, so
`center('Raku', 30, :fill('.'))` gives you twelve dots, a space, the text, a
space and twelve more dots — not thirteen dots on each side.

## The one thing to know

A multi-character `:fill` is repeated **as a unit**, so the field comes out
wider than you asked for by a factor of the fill's length.

```raku name="fill-trap"
use Text::Center;

for '.', '<>', '-=-' -> $f {
    my $r = center('hi', 12, :fill($f));
    say sprintf('fill=%-6s asked for 12, got %2d  [%s]', "'$f'", $r.chars, $r);
}
```

```output
fill='.'    asked for 12, got 12  [.... hi ....]
fill='<>'   asked for 12, got 20  [<><><><> hi <><><><>]
fill='-=-'  asked for 12, got 28  [-=--=--=--=- hi -=--=--=--=-]
```

The sub works out how many pad *slots* it needs and then repeats the whole
fill string that many times, instead of repeating it to cover that many
columns. With a one-character fill the two are the same number and the bug is
invisible; the moment someone reaches for a two-character rule the field is
twenty wide where twelve was asked for, silently. An empty `:fill('')` is
broken the same way from the other direction, giving back a five-character
`" hi  "`.

If you need a repeating multi-character rule, centre with spaces and lay the
rule underneath.

## Where the two engines differ

Nowhere. Every spike in this page produced byte-identical output under Raku++
and Rakudo, including the fill-repetition bug.

Two things to know that are not engine differences. Text that does not fit is
returned **unchanged**, never truncated — `center('abcdefgh', 4)` gives you
all eight characters — so this cannot be relied on to produce a fixed-width
field. And the width is counted in graphemes, which is correct for combining
marks (both spellings of `café` measure four) and wrong for East Asian
characters and emoji, which occupy two terminal columns apiece and so overrun
the field by up to double.
