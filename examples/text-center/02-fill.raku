#!/usr/bin/env rakupp
# Text::Center — Filling with something other than a space
# https://raku.online/modules/text-center/#filling-with-something-other-than-a-space
#
# Install what it needs, then run it:
#     rakupp install Text::Center
#     rakupp 02-fill.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Center;

say center('Raku', 30, :fill('.'));
say center('Contents', 30, :fill('-'));
say center('', 12, :fill('='));
for 7, 8, 9, 10 -> $w {
    say sprintf('w=%2d [%s]', $w, center('ab', $w, :fill('#')));
}

# Output:
#     ............ Raku ............
#     ---------- Contents ----------
#     =====  =====
#     w= 7 [## ab #]
#     w= 8 [## ab ##]
#     w= 9 [### ab ##]
#     w=10 [### ab ###]
