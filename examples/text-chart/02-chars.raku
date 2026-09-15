#!/usr/bin/env rakupp
# Text::Chart — Drawing a chart
# https://raku.online/modules/text-chart/#drawing-a-chart
#
# Install what it needs, then run it:
#     rakupp install Text::Chart
#     rakupp 02-chars.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Chart;

say 'three columns, three characters:';
print vertical(max => 2, :chart-chars<abc>, 2, 2, 2);
say '';
say 'the exported default:';
say '  $default-char = ', $default-char, '  (U+', $default-char.ord.base(16), ')';

# Output:
#     three columns, three characters:
#     abc
#     abc
#     
#     the exported default:
#       $default-char = █  (U+2588)
