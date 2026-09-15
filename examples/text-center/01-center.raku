#!/usr/bin/env rakupp
# Text::Center — Centring something
# https://raku.online/modules/text-center/#centring-something
#
# Install what it needs, then run it:
#     rakupp install Text::Center
#     rakupp 01-center.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Center;

say '[' ~ center('Raku', 20) ~ ']';
say '[' ~ center('odd', 10) ~ ']';
say '[' ~ center('even', 10) ~ ']';
say '[' ~ center(42, 9) ~ ']';
say '[' ~ center('', 6) ~ ']';

# Output:
#     [        Raku        ]
#     [    odd   ]
#     [   even   ]
#     [    42   ]
#     [      ]
