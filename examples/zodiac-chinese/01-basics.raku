#!/usr/bin/env rakupp
# Zodiac::Chinese — Using it
# https://raku.online/modules/zodiac-chinese/#using-it
#
# Install what it needs, then run it:
#     rakupp install Zodiac::Chinese
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Zodiac::Chinese;

for 2018 .. 2025 -> $y {
    my $z = ChineseZodiac.new(DateTime.new(year => $y, month => 6, day => 15));
    say sprintf('%d  %-4s %-6s %s', $y, $z.direction, $z.element, $z.sign);
}

# Output:
#     2018  yang earth  dog
#     2019  yin  earth  pig
#     2020  yang metal  rat
#     2021  yin  metal  ox
#     2022  yang water  tiger
#     2023  yin  water  rabbit
#     2024  yang wood   dragon
#     2025  yin  wood   snake
