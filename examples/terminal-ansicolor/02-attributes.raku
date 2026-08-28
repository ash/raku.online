#!/usr/bin/env rakupp
# Terminal::ANSIColor — Attributes, and how they combine
# https://raku.online/modules/terminal-ansicolor/#attributes-and-how-they-combine
#
# Install what it needs, then run it:
#     rakupp install Terminal::ANSIColor
#     rakupp 02-attributes.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::ANSIColor;

my $s = color('bold red on_white') ~ 'ALERT' ~ color('reset');
say $s.raku;
say $s.chars;
say $s.subst(/\e\[ <[\d;]>+ m/, '', :g);

# Output:
#     "\x[1B][1;31;47mALERT\x[1B][0m"
#     19
#     ALERT
