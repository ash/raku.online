#!/usr/bin/env rakupp
# Terminal::ANSIColor — Taking it off again
# https://raku.online/modules/terminal-ansicolor/#taking-it-off-again
#
# Install what it needs, then run it:
#     rakupp install Terminal::ANSIColor
#     rakupp 04-strip.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::ANSIColor;

my $painted = colored('red text', 'red');
say colorstrip($painted);
say colorstrip($painted).chars;
say $painted.chars;

# Output:
#     red text
#     8
#     17
