---
name: IRC::TextColor
version: 0.4.1
auth: zef:raku-community-modules
kind: Distribution · terminal
summary: IRC's in-band colour codes with names, plus a converter that turns
  ANSI terminal escapes into the IRC equivalents so console output can be
  relayed to a channel.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:raku-community-modules/IRC::TextColor
source: https://github.com/raku-community-modules/IRC-TextColor
---

## What it is for

IRC has no markup. Colour and emphasis travel as control bytes mixed into
the message itself: byte 3 followed by a two-digit colour number, byte 2
for bold, byte 15 to put everything back. A bot that wants to highlight an
error, or relay coloured build output to a channel, has to emit those bytes
in the right order, and they are exactly the kind of thing that is easier
to name than to remember.

This distribution names them, and adds the conversion nobody wants to write
twice: a string that already carries ANSI terminal escapes, rewritten into
the IRC equivalents.

## Colour, style, and a bridge from ANSI

```raku name="colours"
use IRC::TextColor;

say irc-style-text('alert', :color<red>).raku;
say irc-style-text('alert', :color<red>, :bgcolor<white>).raku;
say irc-style-text('alert', :color<green>, :style<bold>).raku;
say irc-style-text('alert', :style<underline>).raku;
say irc-style-text('alert').raku;

say ircstyle('alert', :red).raku;
say ircstyle('alert', :bold, :red).raku;

my $ansi = "\e[31mred\e[0m and \e[1;32mbold green\e[0m";
say ansi-to-irc($ansi).raku;
say ansi-to-irc('no escapes here').raku;
```

```output
"\x[3]04alert\x[F]"
"\x[3]04,00alert\x[F]"
"\x[2]\x[3]03alert\x[F]"
"\x[1F]alert\x[F]"
"alert"
"\x[3]04alert\x[F]"
"\x[2]\x[3]04alert\x[F]"
"\x[3]04red\x[F] and \x[2]\x[3]03bold green\x[F]"
"no escapes here"
```

The escapes are shown through `.raku` so they are legible; sent to a
channel they are invisible and the word arrives coloured. `\x[3]04` is
"colour 4", which is IRC's red, and `\x[F]` is the reset that every styled
run should end with. `ircstyle` is the shorter spelling, taking the colour
and style as flags rather than as values.

`ansi-to-irc` is the useful one in practice: build your output for a
terminal with any of the usual ANSI helpers, then translate it on the way
to the channel.

## The one thing to know

An unrecognised colour or style name is silently dropped. No exception, no
warning — you get the bare text back, which looks exactly like a successful
call on a string that happened to need no markup:

```raku name="unknown-names"
use IRC::TextColor;

for <red purple cyan magenta crimson> -> $c {
    say sprintf('%-8s %s', $c, irc-style-text('x', :color($c)).raku);
}
say irc-style-text('x', :style<bold>, :color<crimson>).raku;
say ircstyle('x', :bold(False)).raku;
say ircstyle('x', :!red).raku;
```

```output
red      "\x[3]04x\x[F]"
purple   "\x[3]06x\x[F]"
cyan     "x"
magenta  "x"
crimson  "x"
"\x[2]x\x[F]"
"\x[2]x\x[F]"
"\x[3]04x\x[F]"
```

`cyan` and `magenta` are the traps, because they are standard ANSI names
and perfectly reasonable guesses. IRC's table spells them `light-cyan` and
`purple`, so both come back unstyled and you find out when the channel
shows plain text. A wrong colour does not take the style with it, as the
sixth line shows.

The last two lines are the other surprise. `ircstyle` keys off the *names*
of its named arguments and never looks at their values, so `:bold(False)`
and even `:!red` apply the style. Building that argument list from booleans
does not work; include the argument only when you want the effect.
