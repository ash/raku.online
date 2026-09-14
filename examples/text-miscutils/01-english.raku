#!/usr/bin/env rakupp
# Text::MiscUtils — English, and layout
# https://raku.online/modules/text-miscutils/#english-and-layout
#
# Install what it needs, then run it:
#     rakupp install Text::MiscUtils
#     rakupp 01-english.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::MiscUtils::English;

say (1, 2, 3, 11, 22).map({ ordinal($_) }).join(' ');

for 0, 1, 2 -> $n { say "$n file{_s($n)}" }
say '3 bo', _s(3, 'xes', 'x');

# Output:
#     1st 2nd 3rd 11th 22nd
#     0 files
#     1 file
#     2 files
#     3 boxes
