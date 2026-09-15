#!/usr/bin/env rakupp
# IRC::TextColor — Colour, style, and a bridge from ANSI
# https://raku.online/modules/irc-textcolor/#colour-style-and-a-bridge-from-ansi
#
# Install what it needs, then run it:
#     rakupp install IRC::TextColor
#     rakupp 01-colours.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     "\x[3]04alert\x[F]"
#     "\x[3]04,00alert\x[F]"
#     "\x[2]\x[3]03alert\x[F]"
#     "\x[1F]alert\x[F]"
#     "alert"
#     "\x[3]04alert\x[F]"
#     "\x[2]\x[3]04alert\x[F]"
#     "\x[3]04red\x[F] and \x[2]\x[3]03bold green\x[F]"
#     "no escapes here"
