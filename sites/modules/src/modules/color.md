---
name: Color
version: 1.004001
auth: zef:raku-community-modules
kind: Distribution · graphics
summary: A color as an object — construct it from hex, RGB, HSL, HSV or
  CMYK, convert between them all, and adjust it with lighten, darken,
  saturate, invert and arithmetic.
status: full
license: Artistic-2.0
suite: 8 files, green
tested: 2026-08-28
raku-land: https://raku.land/zef:raku-community-modules/Color
source: https://github.com/raku-community-modules/Color
---

## What it is for

The moment a program touches color — a chart, a theme, terminal output, an
SVG — it needs the conversions everyone half-remembers: hex to RGB, RGB to
HSL, "this but darker". This module is those conversions as one object.
Feed `Color.new` whatever notation you have; ask it for whichever you
need:

```raku name="one-color"
use Color;

my $c = Color.new('#ff8800');
say ~$c;
say $c.rgb;
say $c.to-string('rgb');
say $c.to-string('hsl');
say Color.new(:hsl[210, 80, 40]).to-string('hex');
say Color.new(r => 255, g => 136, b => 0) eqv $c;
```

```output
#FF8800
(255 136 0)
rgb(255, 136, 0)
hsl(32, 100, 50)
#1466B7
True
```

A color stringifies to its hex form, `.rgb`/`.hsl`/`.hsv`/`.cmyk` return
the numbers, and `.to-string` renders the CSS-ready spellings. The last
two lines show construction going the other way — from an HSL triple, and
from named RGB parts — and that the same color is the same color, however
it was written down.

## This, but darker

The manipulation methods are why the object beats a hex string in your
config. Each returns a **new** `Color`, so a base color can fan out into
a palette without mutating anything:

```raku name="palette"
use Color;

my $brand = Color.new('#ff8800');
say $brand.darken(20).to-string('hex');
say $brand.lighten(20).to-string('hex');
say $brand.desaturate(50).to-string('hex');
say $brand.invert.to-string('hex');
```

```output
#995100
#FFB766
#BF833F
#0077FF
```

`darken`/`lighten` move the HSL lightness by so many percentage points,
`saturate`/`desaturate` do the same for saturation, and `invert` flips
every channel — the four operations that turn one brand color into
hover, muted and contrast variants.

## Color arithmetic

The `Color::Operators` module (loaded with the class) overloads the
arithmetic operators, clipping at the channel boundaries rather than
wrapping:

```raku name="operators"
use Color;

say (Color.new('#404040') * 2).to-string('hex');
say (Color.new('#ff8800') + Color.new('#0000ff')).to-string('hex');
```

```output
#808080
#FF88FF
```

Addition saturates — `FF + 00` stays `FF` — which is what you want when
mixing toward white. There is an alpha channel too (`.a`, hex forms
`hex8`/`hex4`), left out of the arithmetic by default; setting
`.alpha-math = True` opts it in per color.

## Where the two engines differ

Nothing on this page. Every constructor spelling, all four conversion
targets, the manipulation methods and the operator overloads answer
identically under Raku++ and Rakudo — including the misfit case: a
constructor call that matches no candidate (say, `:h/:s/:l` as separate
named arguments instead of `:hsl[…]`) is rejected by both engines alike.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install Color`; it depends on nothing outside
   the core.
3. **Test** — the distribution's own suite: 8 files, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

The suite is a workout in disguise: sixteen `multi method new` candidates
dispatching on names, positionals and `where`-constrained arrays, plus a
sub-`proto` layer for the conversions — thirteen distributions depend on
it, and its going green says multi-dispatch with coercion types agrees
between the engines down to which call is *refused*.
