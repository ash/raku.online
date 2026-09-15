#!/usr/bin/env rakupp
# Text::Lorem — The odd one out
# https://raku.online/modules/text-lorem/#the-odd-one-out
#
# Install what it needs, then run it:
#     rakupp install Text::Lorem
#     rakupp 03-zero.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Lorem;

my $l = Text::Lorem.new;
say 'words(0)      : ', $l.words(0).raku;
say 'sentences(0)  : ', $l.sentences(0).raku;
say 'paragraphs(0) : ', $l.paragraphs(0).raku;

# Output:
#     words(0)      : "."
#     sentences(0)  : ""
#     paragraphs(0) : ""
