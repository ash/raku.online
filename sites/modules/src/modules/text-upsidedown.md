---
name: Text::UpsideDown
version: 1.0.0
auth: github:mcsnolte
kind: Distribution · text
summary: The "flipped" Unicode imitation — an exact involution over printable
  ASCII, because the table is merged with its own inverse.
status: full
suite: 2 files, green
tested: 2026-09-15
license: none stated
depends: none beyond the core
raku-land: https://raku.land/github:mcsnolte/Text::UpsideDown
source: git://github.com/mcsnolte/Text-UpsideDown.git
---

## What it is for

`¡pʃɹoM 'oʃʃǝH` — text that looks like it has been rotated 180°, made from
Unicode characters that happen to resemble upside-down Latin ones. It shows up
in chat, in signatures and in novelty output.

The transform is two steps: reverse the character order, and substitute each
character for its rotated look-alike.

## Flipping

```raku name="basics"
use Text::UpsideDown;

for 'foo', 'Hello, World!', '0123456789' -> $s {
    say sprintf('  %-16s -> %s', $s.raku, upside_down($s));
}
say '';
say 'the string is FLIPPED first, so it is not a per-character map:';
say '  upside_down("foo") = ', upside_down('foo').raku, ' — not "ɟoo"';
```

```output
  "foo"            -> ooɟ
  "Hello, World!"  -> ¡pʃɹoM 'oʃʃǝH
  "0123456789"     -> 68ㄥ954Ɛ2⇂0

the string is FLIPPED first, so it is not a per-character map:
  upside_down("foo") = "ooɟ" — not "ɟoo"
```

## The one thing to know

`upside_down` is an exact involution over all printable ASCII: applying it
twice returns the original string, every time. The lookup table is merged with
its own inverse, which makes it a usable two-way transform rather than a
one-way toy.

```raku name="involution"
use Text::UpsideDown;

my @fail = (0x20 .. 0x7E).map(*.chr).grep({ upside_down(upside_down($_)) ne $_ });
say 'printable ASCII characters that do NOT round-trip : ', @fail.elems;
say '';
say 'so the transform is reversible:';
my $s = 'Hello, World!';
say '  ', $s.raku;
say '  ', upside_down($s).raku;
say '  ', upside_down(upside_down($s)).raku;
say '';
say 'the corollary is that some ASCII letters map to OTHER ASCII letters:';
say '  M and W are each other`s flip, so upside_down("MW") = ',
    upside_down('MW').raku;
say '';
my @fixed = (0x20 .. 0x7E).map(*.chr).grep({ upside_down($_) eq $_ });
say 'characters that are their own flip : ', @fixed.join;
```

```output
printable ASCII characters that do NOT round-trip : 0

so the transform is reversible:
  "Hello, World!"
  "¡pʃɹoM 'oʃʃǝH"
  "Hello, World!"

the corollary is that some ASCII letters map to OTHER ASCII letters:
  M and W are each other`s flip, so upside_down("MW") = "MW"

characters that are their own flip :  #$%+-/02458:=@HIOSXZ\`osxz|~
```

## What it does not touch

```raku name="untouched"
use Text::UpsideDown;

say 'unmapped characters still get REVERSED, just not substituted:';
say '  ', upside_down("\c[CJK UNIFIED IDEOGRAPH-65E5]\c[CJK UNIFIED IDEOGRAPH-672C] \c[SNOWMAN]").raku;
say '';
say 'and a precomposed accented letter is one grapheme that is not in the';
say 'table, so only its position moves:';
my $acc = "e\c[COMBINING ACUTE ACCENT]f";
say '  input  : ', $acc.raku, '  (', $acc.chars, ' graphemes)';
say '  output : ', upside_down($acc).raku;
say '';
say 'newlines are characters like any other, so a multi-line string comes';
say 'back reversed across the line break:';
say '  ', upside_down("ab\ncd").raku;
```

```output
unmapped characters still get REVERSED, just not substituted:
  "☃ 本日"

and a precomposed accented letter is one grapheme that is not in the
table, so only its position moves:
  input  : "éf"  (2 graphemes)
  output : "ɟé"

newlines are characters like any other, so a multi-line string comes
back reversed across the line break:
  "pɔ\nqɐ"
```

## Where the two engines differ

Nothing in the substitution. One argument shape differs, and only for a type
object: `upside_down(Int)` is a run-time binding failure under Raku++ and a
compile-time refusal under Rakudo, while a literal `upside_down(42)` is
rejected at compile time on both.

```raku name="types"
use Text::UpsideDown;

say 'the parameter is Str with no Cool coercion, so coerce yourself:';
my $n = 42;
say '  upside_down($n.Str) = ', upside_down($n.Str).raku;
say '';
say 'there is one Unicode subtlety worth knowing before you scan a wide';
say 'range of codepoints through this function. Raku++ does not NFC-';
say 'normalise Int.chr, so a compatibility character such as the Kelvin';
say 'sign stays distinct from the letter K there and folds to it on';
say 'Rakudo — which makes a "does every codepoint round-trip?" sweep';
say 'disagree between the engines for about 565 codepoints.';
say '';
say 'printable ASCII is unaffected, which is what the table covers:';
my @fail = (0x20 .. 0x7E).map(*.chr).grep({ upside_down(upside_down($_)) ne $_ });
say '  ASCII failures : ', @fail.elems;
```

```output
the parameter is Str with no Cool coercion, so coerce yourself:
  upside_down($n.Str) = "24"

there is one Unicode subtlety worth knowing before you scan a wide
range of codepoints through this function. Raku++ does not NFC-
normalise Int.chr, so a compatibility character such as the Kelvin
sign stays distinct from the letter K there and folds to it on
Rakudo — which makes a "does every codepoint round-trip?" sweep
disagree between the engines for about 565 codepoints.

printable ASCII is unaffected, which is what the table covers:
  ASCII failures : 0
```

The distribution is not in the zef index; `rakupp test` resolves it from the
REA archive and notes that the index path carries no checksum, so TLS is the
only integrity check on the fetch. The META6 states no `auth` and no
`license`; the `auth` used above comes from the ecosystem index and from the
module's own `unit module` line.
