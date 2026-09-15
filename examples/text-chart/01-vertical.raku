#!/usr/bin/env rakupp
# Text::Chart — Drawing a chart
# https://raku.online/modules/text-chart/#drawing-a-chart
#
# Install what it needs, then run it:
#     rakupp install Text::Chart
#     rakupp 01-vertical.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Chart;

say 'vertical(max => 3, 1, 2, 3):';
print vertical(max => 3, 1, 2, 3);
say '';
say 'values above max are clipped, values at or below 0 draw nothing:';
print vertical(max => 3, 0, 3, 5);

# Output:
#     vertical(max => 3, 1, 2, 3):
#       █
#      ██
#     ███
#     
#     values above max are clipped, values at or below 0 draw nothing:
#      ██
#      ██
#      ██
