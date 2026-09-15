#!/usr/bin/env rakupp
# IRC::TextColor — The one thing to know
# https://raku.online/modules/irc-textcolor/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install IRC::TextColor
#     rakupp 02-unknown-names.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use IRC::TextColor;

for <red purple cyan magenta crimson> -> $c {
    say sprintf('%-8s %s', $c, irc-style-text('x', :color($c)).raku);
}
say irc-style-text('x', :style<bold>, :color<crimson>).raku;
say ircstyle('x', :bold(False)).raku;
say ircstyle('x', :!red).raku;

# Output:
#     red      "\x[3]04x\x[F]"
#     purple   "\x[3]06x\x[F]"
#     cyan     "x"
#     magenta  "x"
#     crimson  "x"
#     "\x[2]x\x[F]"
#     "\x[2]x\x[F]"
#     "\x[3]04x\x[F]"
