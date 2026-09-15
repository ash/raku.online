#!/usr/bin/env rakupp
# Text::BorderedBlock — Boxing a block
# https://raku.online/modules/text-borderedblock/#boxing-a-block
#
# Install what it needs, then run it:
#     rakupp install Text::BorderedBlock
#     rakupp 01-box.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::BorderedBlock;

say Text::BorderedBlock.new(
    content       => "hello\nworld",
    minimum-width => 20,
).render;

say Text::BorderedBlock.new(
    content       => "the body of the block",
    header        => 'HEADING',
    footer        => 'a footnote',
    minimum-width => 30,
).render;

# Output:
#     ┏━━━━━━━━━━━━━━━━━━━━┓
#     ┃hello               ┃
#     ┃world               ┃
#     ┗━━━━━━━━━━━━━━━━━━━━┛
#     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#     ┃HEADING                       ┃
#     ┠──────────────────────────────┨
#     ┃the body of the block         ┃
#     ┠──────────────────────────────┨
#     ┃a footnote                    ┃
#     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
