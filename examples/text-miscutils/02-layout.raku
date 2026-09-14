#!/usr/bin/env rakupp
# Text::MiscUtils — English, and layout
# https://raku.online/modules/text-miscutils/#english-and-layout
#
# Install what it needs, then run it:
#     rakupp install Text::MiscUtils
#     rakupp 02-layout.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::MiscUtils::Layout;

say '[' ~ $_ ~ ']' for wrap-text(24, 'The quick brown fox jumps over the lazy dog');
say duospace-width('hello 世界'), ' columns, ', 'hello 世界'.chars, ' characters';

# Output:
#     [The quick brown fox     ]
#     [jumps over the lazy dog ]
#     10 columns, 8 characters
