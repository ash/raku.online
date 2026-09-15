---
name: Term::Size
version: 0.1.1
auth: zef:apogee
kind: Distribution · terminal
summary: Terminal width and height in cells and pixels, from a bundled C
  helper — where only `populate` ever reports failure.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:apogee/Term::Size
source: https://github.com/m-doughty/Term-Size.git
---

## What it is for

Wrapping output to the terminal, drawing a progress bar, or laying out a table
needs the window size. This distribution asks the kernel with a
`TIOCGWINSZ`-style ioctl, and additionally tries the kitty protocol, which
reports pixel dimensions and cell size as well as rows and columns.

## Asking

```raku name="basics"
use Term::Size;

my $ts = Term::Size.new;
my $ok = $ts.populate;

say 'STDOUT is a tty : ', $*OUT.t;
say 'populate failed : ', ($ok ~~ Failure).so;
say '  message       : ', ($ok ~~ Failure) ?? $ok.exception.message !! '(none)';
say '';
for <term-width-cells term-height-cells term-width-px term-height-px
     cell-width-px cell-height-px> -> $m {
    say sprintf('  %-18s %s', $m, $ts."$m"());
}
say '';
say 'this page is built with no controlling terminal, so every value is 0';
say 'and populate returns a Failure. On a real terminal the same six';
say 'accessors answer the window size.';
```

```output
STDOUT is a tty : False
populate failed : True
  message       : Failed to get term size

  term-width-cells   0
  term-height-cells  0
  term-width-px      0
  term-height-px     0
  cell-width-px      0
  cell-height-px     0

this page is built with no controlling terminal, so every value is 0
and populate returns a Failure. On a real terminal the same six
accessors answer the window size.
```

## The one thing to know

The six accessors **never** fail — they return plain `Int` `0`. Only
`populate` reports the error, and it does so as a `Failure` you can drop on
the floor.

```raku name="zero"
use Term::Size;

my $ts = Term::Size.new;
my $r = $ts.populate;               # a Failure here, if there is no terminal
$r.so if $r ~~ Failure;             # mark it handled so it cannot detonate

my $w = $ts.term-width-cells;
say 'term-width-cells : ', $w;
say '  type           : ', $w.WHAT.^name;
say '  ~~ Failure     : ', ($w ~~ Failure);
say '';
say 'so the natural code —';
say '  my $t = Term::Size.new; $t.populate; say $t.term-width-cells;';
say '— prints 0, with no warning anywhere.';
say '';
say 'and the usual defensive idiom hides it:';
say '  width || 80  = ', ($w || 80), '   <- 80 in BOTH the "no terminal"';
say '                        case and a hypothetical real 0-column one';
say '  width - 2    = ', ($w - 2), '  <- a negative layout';
say '';
say 'check populate`s return value; nothing downstream will tell you:';
sub terminal-width(Int $fallback = 80) {
    my $t = Term::Size.new;
    my $r = $t.populate;
    return $fallback if $r ~~ Failure;
    $t.term-width-cells || $fallback
}
say '  terminal-width() = ', terminal-width();
```

```output
term-width-cells : 0
  type           : Int
  ~~ Failure     : False

so the natural code —
  my $t = Term::Size.new; $t.populate; say $t.term-width-cells;
— prints 0, with no warning anywhere.

and the usual defensive idiom hides it:
  width || 80  = 80   <- 80 in BOTH the "no terminal"
                        case and a hypothetical real 0-column one
  width - 2    = -2  <- a negative layout

check populate`s return value; nothing downstream will tell you:
  terminal-width() = 80
```

## The native layer

```raku name="native"
use Term::Size;

say 'the class is a thin wrapper over two C helpers and two CStructs:';
say '  get_termsize(TermSize)            — the ioctl';
say '  get_kitty_termsize(TermSize, CellSize) — the kitty query';
say '';
say 'both return -1 with no terminal, and every struct field stays 0.';
say 'the native library itself loads fine — the failure is the ioctl, not';
say 'the %?RESOURCES lookup.';
say '';
say 'two shapes worth knowing:';
say '  TermSize.cell_width / cell_height divide by ws_col / ws_row and';
say '  return 0 rather than dividing by zero — another zero meaning';
say '  "unknown".';
say '  CellSize.ws_cwidth and ws_cheight are `is rw`, so a caller can';
say '  overwrite the measured cell size. TermSize`s fields are read-only.';
```

```output
the class is a thin wrapper over two C helpers and two CStructs:
  get_termsize(TermSize)            — the ioctl
  get_kitty_termsize(TermSize, CellSize) — the kitty query

both return -1 with no terminal, and every struct field stays 0.
the native library itself loads fine — the failure is the ioctl, not
the %?RESOURCES lookup.

two shapes worth knowing:
  TermSize.cell_width / cell_height divide by ws_col / ws_row and
  return 0 rather than dividing by zero — another zero meaning
  "unknown".
  CellSize.ws_cwidth and ws_cheight are `is rw`, so a caller can
  overwrite the measured cell size. TermSize`s fields are read-only.
```

## Where the two engines differ

Two, and one of them will surprise you in a log file. `.raku` is overridden to
return a human report rather than an evaluable representation — and under
Rakudo that also changes `.gist`, so `say $ts` prints a six-line block there
and the ordinary structural gist under Raku++.

```raku name="gist"
use Term::Size;

my $ts = Term::Size.new;
my $r = $ts.populate;
$r.so if $r ~~ Failure;

say 'the overridden .raku is a REPORT, identical on both engines:';
print $ts.raku;
say '';
say 'but `say $ts` is not. Rakudo falls back to the overridden .raku for';
say '.gist and prints the same six lines; Raku++ prints the structural';
say 'gist. Anything logging $ts, or using dd, differs.';
say '';
say 'print the accessors, not the object.';
say '';
say 'the other difference: after `use Term::Size` alone, Raku++ leaks';
say 'Term::Size::Native`s exports into your scope, so `my TermSize $x .= new`';
say 'compiles there and is "Type TermSize is not declared" on Rakudo.';
say 'Use the qualified name, or `use Term::Size::Native` explicitly.';
```

```output
the overridden .raku is a REPORT, identical on both engines:
Terminal width (px):     Not Detected
Terminal height (px):    Not Detected
Terminal width (cells):  Not Detected
Terminal height (cells): Not Detected
Cell width (px):         Not Detected
Cell height (px):        Not Detected
but `say $ts` is not. Rakudo falls back to the overridden .raku for
.gist and prints the same six lines; Raku++ prints the structural
gist. Anything logging $ts, or using dd, differs.

print the accessors, not the object.

the other difference: after `use Term::Size` alone, Raku++ leaks
Term::Size::Native`s exports into your scope, so `my TermSize $x .= new`
compiles there and is "Type TermSize is not declared" on Rakudo.
Use the qualified name, or `use Term::Size::Native` explicitly.
```
