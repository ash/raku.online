#!/usr/bin/env rakupp
# Zodiac::Chinese — The one thing to know
# https://raku.online/modules/zodiac-chinese/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Zodiac::Chinese
#     rakupp 04-boundary.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Zodiac::Chinese;

sub sign($y, $m, $d) {
    ChineseZodiac.new(DateTime.new(year => $y, month => $m, day => $d)).sign
}

say 'the module`s own boundary:';
say '  2020-01-31 -> ', sign(2020, 1, 31), '      2020-02-01 -> ', sign(2020, 2, 1);
say '';
say 'against the published new-year dates:';
say '  CNY 2020-01-25 begins the Metal Rat';
say '    the day itself 2020-01-25 -> ', sign(2020, 1, 25), '   WRONG';
say '  CNY 2023-01-22 begins the Water Rabbit';
say '    the day itself 2023-01-22 -> ', sign(2023, 1, 22), '  WRONG';
say '  CNY 2024-02-10 begins the Wood Dragon';
say '    the day before 2024-02-09 -> ', sign(2024, 2, 9), ' WRONG';
say '';
say 'do not use this for a date in the second half of January or the';
say 'first three weeks of February.';

# Output:
#     the module`s own boundary:
#       2020-01-31 -> pig      2020-02-01 -> rat
#     
#     against the published new-year dates:
#       CNY 2020-01-25 begins the Metal Rat
#         the day itself 2020-01-25 -> pig   WRONG
#       CNY 2023-01-22 begins the Water Rabbit
#         the day itself 2023-01-22 -> tiger  WRONG
#       CNY 2024-02-10 begins the Wood Dragon
#         the day before 2024-02-09 -> dragon WRONG
#     
#     do not use this for a date in the second half of January or the
#     first three weeks of February.
