#!/usr/bin/env rakupp
# Text::BorderedBlock — How the width is chosen
# https://raku.online/modules/text-borderedblock/#how-the-width-is-chosen
#
# Install what it needs, then run it:
#     rakupp install Text::BorderedBlock
#     rakupp 02-width.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::BorderedBlock;

sub show($label, |c) {
    say "--- $label";
    say Text::BorderedBlock.new(|c).render;
}

show 'minimum wins',      content => 'hi', minimum-width => 14;
show 'content wins',      content => '0123456789ABCDEFGHIJ', minimum-width => 10;
show 'the header counts', content => 'hi', header => 'a rather long header', minimum-width => 5;
show 'empty content',     content => '', minimum-width => 8;

# Output:
#     --- minimum wins
#     ┏━━━━━━━━━━━━━━┓
#     ┃hi            ┃
#     ┗━━━━━━━━━━━━━━┛
#     --- content wins
#     ┏━━━━━━━━━━━━━━━━━━━━┓
#     ┃0123456789ABCDEFGHIJ┃
#     ┗━━━━━━━━━━━━━━━━━━━━┛
#     --- the header counts
#     ┏━━━━━━━━━━━━━━━━━━━━┓
#     ┃a rather long header┃
#     ┠────────────────────┨
#     ┃hi                  ┃
#     ┗━━━━━━━━━━━━━━━━━━━━┛
#     --- empty content
#     ┏━━━━━━━━┓
#     ┗━━━━━━━━┛
