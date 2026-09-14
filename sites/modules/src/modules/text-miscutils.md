---
name: Text::MiscUtils
version: 0.0.13
auth: zef:japhb
kind: Distribution · text
summary: Four small text utilities under one distribution — English plurals and
  ordinals, terminal-aware wrapping and column widths, and the variation
  selectors that decide whether a glyph is drawn as emoji.
status: full
suite: 4 files, green
tested: 2026-09-14
license: Artistic-2.0
depends: Terminal::ANSIColor
raku-land: https://raku.land/zef:japhb/Text::MiscUtils
source: https://github.com/japhb/Text-MiscUtils
---

## What it is for

These are the functions you write badly, in a hurry, at the bottom of a script:
the one that decides between "1 file" and "2 files", the one that turns 22 into
"22nd", the one that wraps a paragraph to the terminal without cutting a CJK
character in half. Each is a few lines and each has an edge case — 11 is not
"11st", and a wide character is not one column — so having them written once
and tested is worth more than the line count suggests.

The distribution is a namespace rather than a single module: `::English`,
`::Layout` and `::Emojify` are separate units, imported separately.

## English, and layout

`::English` is two subs. `_s` gives the plural suffix for a count, taking the
suffix pair as optional arguments when "s" is not the right one, and `ordinal`
gets the teens right:

```raku name="english"
use Text::MiscUtils::English;

say (1, 2, 3, 11, 22).map({ ordinal($_) }).join(' ');

for 0, 1, 2 -> $n { say "$n file{_s($n)}" }
say '3 bo', _s(3, 'xes', 'x');
```

```output
1st 2nd 3rd 11th 22nd
0 files
1 file
2 files
3 boxes
```

`::Layout` measures and wraps in *columns* rather than characters, so it agrees
with what a terminal will actually draw:

```raku name="layout"
use Text::MiscUtils::Layout;

say '[' ~ $_ ~ ']' for wrap-text(24, 'The quick brown fox jumps over the lazy dog');
say duospace-width('hello 世界'), ' columns, ', 'hello 世界'.chars, ' characters';
```

```output
[The quick brown fox     ]
[jumps over the lazy dog ]
10 columns, 8 characters
```

The brackets are there to show something the fence would otherwise hide:
`wrap-text` returns a list of lines each **padded out to the full width**, not
trimmed. That is what you want when the block is going into a column beside
another one, and a surprise if you were expecting bare text — pass
`:!fill-trailing` to `wrap-text`'s sibling `text-wrap` when you want it off.

`::Emojify` is the smallest of the three: `emojify` appends U+FE0F to a
character so a dual-presentation glyph is drawn in colour, and `textify`
appends U+FE0E so it is drawn as text.

## The one thing to know

`use Text::MiscUtils;` imports nothing at all. The top-level unit exists to hold
the namespace and exports no subs, so the natural first line gets you a clean
compile and then `Undefined routine 'ordinal'` at the point of use — the same
message on both engines, which is at least an unambiguous one.

Import the unit you want by name: `use Text::MiscUtils::English;`,
`use Text::MiscUtils::Layout;`, `use Text::MiscUtils::Emojify;`. There is no
single import that brings in all three.
