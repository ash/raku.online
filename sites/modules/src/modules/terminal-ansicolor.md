---
name: Terminal::ANSIColor
version: 0.14
auth: zef:raku-community-modules
kind: Distribution · terminal
summary: Colour and style for terminal output, by name rather than by escape
  code — and one function to take it all back off again.
status: full
license: Artistic-2.0
suite: 1 file, green
tested: 2026-08-28
raku-land: https://raku.land/zef:raku-community-modules/Terminal::ANSIColor
source: https://github.com/raku-community-modules/Terminal-ANSIColor
---

## What it is for

A command-line program that says everything in one colour makes the reader do
the scanning. One red word and the error is found instantly. The escape codes
that do it are short but unmemorable — `\e[1;31m` — and this module lets you
write the names instead:

```raku name="tour"
use Terminal::ANSIColor;

say colored('warning', 'bold yellow').raku;
say colored('ok', 'green').raku;
say color('reset').raku;
```

```output
"\x[1B][1;33mwarning\x[1B][0m"
"\x[1B][32mok\x[1B][0m"
"\x[1B][0m"
```

The examples on this page print `.raku` rather than the string itself, because
what is interesting here is the bytes — and because a web page cannot show you
a terminal. Run any of them without the `.raku` and you get the colour.

Two functions do nearly everything. **`colored($text, $attrs)`** wraps text and
resets afterwards, which is what you want almost always. **`color($attrs)`**
gives you just the escape sequence, for when you are building a longer line and
want to switch attributes partway through — in which case ending with
`color('reset')` is your job.

## Attributes, and how they combine

An attribute string is space-separated words: a foreground colour, a background
colour spelled `on_…`, and any number of styles.

```raku name="attributes"
use Terminal::ANSIColor;

my $s = color('bold red on_white') ~ 'ALERT' ~ color('reset');
say $s.raku;
say $s.chars;
say $s.subst(/\e\[ <[\d;]>+ m/, '', :g);
```

```output
"\x[1B][1;31;47mALERT\x[1B][0m"
19
ALERT
```

Note the second line. `'ALERT'` is five characters; the coloured version is
nineteen, because the escape sequences are part of the string. That is the
single thing to remember about this module: **colour changes `.chars`**. Column
alignment computed on a coloured string will be wrong, and so will truncation.
Lay out the plain text, then colour it.

The names are the usual set — `black red green yellow blue magenta cyan white`,
their `bright_` variants, `on_` forms of all of them, and the styles `bold`,
`italic`, `underline`, `inverse`, `blink`, `conceal`, `strike`.

## 256 colours

A number is a 256-colour index, and `on_` in front of it is the background
form. The `38;5;<n>` spelling works too, for when you have the raw code from
somewhere else:

```raku name="palette"
use Terminal::ANSIColor;

say color('202').raku;
say color('on_17').raku;
say colored('cool', '39').raku;
```

```output
"\x[1B][38;5;202m"
"\x[1B][48;5;17m"
"\x[1B][38;5;39mcool\x[1B][0m"
```

An attribute the module does not recognise throws rather than being ignored —
`Invalid attribute name '38;5;30'` for a semicolon-joined form, on both engines
— so a typo in a colour name is a loud failure, not a line that quietly comes
out plain.

## Taking it off again

`colorstrip` removes every escape sequence. It is what you want when the same
text goes both to a terminal and to a log file, and it is what makes coloured
output testable:

```raku name="strip"
use Terminal::ANSIColor;

my $painted = colored('red text', 'red');
say colorstrip($painted);
say colorstrip($painted).chars;
say $painted.chars;
```

```output
red text
8
17
```

The honest rule for a program that colours its output: decide once, at startup,
whether the destination is a terminal — `$*OUT.t` answers that — and if it is
not, either skip the colouring or `colorstrip` on the way out. Escape codes in
a redirected file are noise, and in a pipe they break the next program's
parsing.

```raku name="table"
use Terminal::ANSIColor;

my %row = ok => 'green', warn => 'yellow', fail => 'bold red';
for %row.keys.sort -> $k {
    say colorstrip(colored($k.uc, %row{$k}));
}
```

```output
FAIL
OK
WARN
```

## Where the two engines differ

Nothing on this page, and nothing found off it. Every example prints the same
bytes under Raku++ and under Rakudo, twice on each.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install Terminal::ANSIColor`, no dependencies to pull.
3. **Test** — the distribution's own suite: 1 file, green.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

Nothing had to be fixed for this one. It was among the first four modules the
ecosystem campaign measured — in July 2026, when nineteen of the top fifty
distributions matched Rakudo's output and nine were outright broken — and it
was already in the matching column, along with JSON::Fast, File::Temp and
Method::Also. A page that says the engine had to learn nothing is worth having
beside the ones that list ten fixes: it is the same measurement, run on a
module that happened to ask for nothing the engine did not have.
