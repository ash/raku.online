---
name: Terminal::ANSI
version: 0.0.25
auth: cpan:bduggan
kind: Distribution · terminal
summary: The ANSI escape sequences with names — bold, colour, cursor movement,
  alternate screen — offered twice over: as subs that write to the terminal,
  and as an object whose methods hand you the string instead.
status: full
suite: 8 files, green
tested: 2026-09-14
license: MIT
depends: OO::Monitors
raku-land: https://raku.land/cpan:bduggan/Terminal::ANSI
source: https://git.sr.ht/~bduggan/raku-terminal-ansi
---

## What it is for

A terminal program that wants colour, or wants to put a character at row 12
column 40, talks to the terminal in escape sequences: `ESC [ 1 m` for bold,
`ESC [ 12 ; 40 H` to move. They are short enough to inline and just cryptic
enough that a typo shows up as garbage on screen rather than as an error.

This distribution names them. Fifty-one exported subs cover attributes
(`bold`, `italic`, `underline`, `strike`, `blink`), colour by palette index or
by RGB triple, the cursor (`move-to`, `save-cursor`, `cursor-up`), the screen
(`clear-screen`, `save-screen`, `erase-to-end-of-line`), and scroll regions.

## Two units, and the difference matters

`Terminal::ANSI` exports subs that **write the escape to standard output** and
return `True`. `Terminal::ANSI::OO` exports a single term `t` whose methods
**return the escape as a string**, to be concatenated into something you print
later:

```raku name="strings"
use Terminal::ANSI::OO;

say t.bold.raku;
say t.red.raku;
say t.text-reset.raku;

say (t.bold ~ 'shouted' ~ t.text-reset).raku;
```

```output
"\x[1B][1m"
"\x[1B][38;5;1m"
"\x[1B][0m"
"\x[1B][1mshouted\x[1B][0m"
```

The escapes are shown through `.raku` here so they are legible on a web page;
printed to a terminal they are invisible and the word comes out bold and red.
`\x[1B]` is `ESC`, and `[0m` is the reset that every sequence you open should
be closed with — leave it out and the next thing written, including your shell
prompt after the program exits, inherits the attribute.

For whole-screen work the procedural side reads better, since you want the
effect and not the string: `print-at($row, $col, $text)`, `save-screen` and
`restore-screen` around a full-screen view, `cursor-off` while you draw.

## The one thing to know

`bold()` and `t.bold` look interchangeable and are not. The bare sub prints
immediately and evaluates to `True`, so building a string out of the
procedural subs gives you the escapes on screen at the wrong moment and the
word `True` where the colour should be:

```raku fragment
# writes the escape NOW, then interpolates "True"
my $label = bold() ~ 'shouted' ~ text-reset();
```

Reach for `Terminal::ANSI::OO` whenever the sequence is going into a variable,
a log line, a `sprintf`, or anything other than the terminal right now. The
procedural subs are for when printing *is* the point.

Worth knowing too: the module can be switched off wholesale. `disable-output`
makes the procedural subs no-ops, which is the hook for a `--no-colour` flag or
for detecting that output is a pipe rather than a terminal — one call at
start-up instead of a conditional at every call site.
