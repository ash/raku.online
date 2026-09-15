#!/usr/bin/env rakupp
# Text::Homoglyph — The whole API
# https://raku.online/modules/text-homoglyph/#the-whole-api
#
# Install what it needs, then run it:
#     rakupp install Text::Homoglyph
#     rakupp 02-coverage.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Homoglyph;

my $covered = (0x20 .. 0x7E).grep({ homoglyphs(.chr).elems > 1 }).elems;
say "printable ASCII with a mapping : $covered of 95";
say '';
for '0', 'O', 'v' -> $c {
    say sprintf('%s -> %s', $c, homoglyphs($c).map({ 'U+' ~ .ord.base(16).fmt('%04s') }).join(' '));
}

# Output:
#     printable ASCII with a mapping : 95 of 95
#     
#     0 -> U+0030 U+004F U+1D67E
#     O -> U+004F U+039F U+041E U+2C9E
#     v -> U+0076 U+1D20 U+2174 U+2228 U+22C1
