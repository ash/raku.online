---
name: Color::Scheme
version: 1.001003
auth: github:holli-holzer
kind: Distribution · colour
summary: Rotate a Color's hue by a list of degree offsets and return the
  resulting colours, with seventeen named offset sets baked in.
status: full
suite: 1 file, green
tested: 2026-09-15
license: BSD-3-Clause
depends: Color
raku-land: https://raku.land/github:holli-holzer/Color::Scheme
source: git://github.com/holli-holzer/raku-Color-Scheme.git
---

## What it is for

Picking a palette from a single brand colour is a solved problem in colour
theory: the harmonies are fixed angular relationships on the hue wheel.
Triadic is 120 degrees apart, tetradic is 90, split-complementary is 150 and
210, and so on.

This distribution knows seventeen of those relationships by name and applies
them.

## Generating a palette

```raku name="scheme"
use Color;
use Color::Scheme;

my $base = Color.new('#1A3CFA');
say 'base : ', $base.to-string('hex');
say '';
for <triadic tetradic analogous split-complementary clash neutral> -> $name {
    my @p = color-scheme($base, $name);
    say sprintf('%-22s %d  %s', $name, @p.elems, @p.map(*.to-string('hex')).join(' '));
}
```

```output
base : #1A3CFA

triadic                3  #1A3CFA #FA1A3C #3CFA1A
tetradic               4  #1A3CFA #FA1AAC #FAD81A #1AFA68
analogous              6  #1A3CFA #681AFA #D81AFA #FA1AAC #FA1A3C #FA681A
split-complementary    3  #1A3CFA #FA681A #1AD1FA
clash                  3  #1A3CFA #FA1AAC #1AFA68
neutral                6  #1A3CFA #301AFA #681AFA #A01AFA #D81AFA #FA1AE4
```

The first colour of every palette is the base itself — the round trip through
hue-saturation-value is lossless for these inputs, so `palette[0]` really is
what you handed in.

## Your own angles

```raku name="angles"
use Color;
use Color::Scheme;

my $base = Color.new('#FF0000');

say 'explicit [0, 180]  : ', color-scheme($base, [0, 180]).map(*.to-string('hex')).join(' ');
say 'explicit [0, 120, 240] : ',
    color-scheme($base, [0, 120, 240]).map(*.to-string('hex')).join(' ');
say '';
say 'angles wrap, and accept negatives and fractions:';
for 360, -120, 720, 12.5 -> $a {
    say sprintf('  %-6s -> %s', $a, color-scheme($base, [$a]).map(*.to-string('hex')).join);
}
say '';
say 'returns an ', color-scheme($base, [0, 180]).^name, ' of ',
    color-scheme($base, [0, 180])[0].^name;
```

```output
explicit [0, 180]  : #FF0000 #00FFFF
explicit [0, 120, 240] : #FF0000 #00FF00 #0000FF

angles wrap, and accept negatives and fractions:
  360    -> #FF0000
  -120   -> #0000FF
  720    -> #FF0000
  12.5   -> #FF3500

returns an Array of Color
```

The angles must be `Real`. A list of numeric *strings* is refused from inside
`Color.rotate` with `expected Real but got Str`.

## The seventeen names

```raku name="names"
use Color::Scheme;

say Color::Scheme::color-scheme-angles.keys.sort.join("\n");
```

```output
analogous
clash
five-tone-a
five-tone-b
five-tone-cs
five-tone-ds
five-tone-es
four-tone-ccw
four-tone-cw
neutral
six-tone-ccw
six-tone-cw
split-complementary
split-complementary-ccw
split-complementary-cw
tetradic
triadic
```

Note the qualification. `color-scheme-angles` is `our`, not exported — so
unqualified it is an undeclared routine on Rakudo. Write the full name.

## The one thing to know

`:debug` is not a logging flag. It writes a file into the current working
directory.

```raku name="debug-trap"
use Color;
use Color::Scheme;

my $dir = $*TMPDIR.add("cs-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

indir $dir, {
    say 'files before : ', $dir.dir.map(*.basename).sort.join(' ') || '(none)';
    my @p = color-scheme(Color.new('#1A3CFA'), 'triadic', :debug);
    say 'palette      : ', @p.map(*.to-string('hex')).join(' ');
    say 'files after  : ', $dir.dir.map(*.basename).sort.join(' ');
    say '';
    my $f = $dir.add('colors.html');
    say 'the file holds a swatch per colour, plus four empty ones:';
    say '  empty background-color rules : ',
        $f.slurp.comb('background-color:;').elems;
}
```

```output
files before : (none)
palette      : #1A3CFA #FA1A3C #3CFA1A
files after  : colors.html

the file holds a swatch per colour, plus four empty ones:
  empty background-color rules : 4
```

`colors.html` is spurted into `$*CWD` with no path argument reaching the
caller, no notice, and no regard for an existing file of that name. Worse, the
generated HTML always indexes seven swatches regardless of how many colours
the scheme has, under a `quietly` block — so a three-colour triadic scheme
produces four empty `background-color:;` rules.

Do not leave `:debug` in anything that ships.

## Where the two engines differ

In the size of that debug file, by one byte per line: the module's own source
has CRLF line endings, and Raku++ keeps the carriage return inside a
multi-line quoted literal where Rakudo strips it. The palettes themselves are
identical.

The other difference is about names rather than colours. Unqualified
`color-scheme-angles` resolves on Raku++ and is a compile-time undeclared
routine on Rakudo, so code developed against one engine fails to compile on
the other. Qualify it.

One thing that is the same on both and worth knowing before you ship a
palette: **a greyscale base colour yields N identical colours**. Hue rotation
of a zero-saturation colour is a no-op, so `#808080` triadic is three copies
of `#808080`.

The distribution's metadata `auth` and the unit's own declared `auth`
disagree, which is why the installer reports a different identity from the
one on raku.land.
