#!/usr/bin/env rakupp
# Color — Color arithmetic
# https://raku.online/modules/color/#color-arithmetic
#
# Install what it needs, then run it:
#     rakupp install Color
#     rakupp 03-operators.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Color;

say (Color.new('#404040') * 2).to-string('hex');
say (Color.new('#ff8800') + Color.new('#0000ff')).to-string('hex');

# Output:
#     #808080
#     #FF88FF
