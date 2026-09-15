#!/usr/bin/env rakupp
# Text::Calendar — The other layouts
# https://raku.online/modules/text-calendar/#the-other-layouts
#
# Install what it needs, then run it:
#     rakupp install Text::Calendar
#     rakupp 03-layouts.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Calendar;

say calendar-month-block(2026, 2, :transposed);
say calendar-month-block(2026, 2, :empty('..'));
say '';
say calendar(2026, [2, 3], :per-row(2));

# Output:
#         February 2026
#     Mo     2  9 16 23
#     Tu     3 10 17 24
#     We     4 11 18 25
#     Th     5 12 19 26
#     Fr     6 13 20 27
#     Sa     7 14 21 28
#     Su  1  8 15 22   
#     February            
#     Mo Tu We Th Fr Sa Su
#     .. .. .. .. .. ..  1
#      2  3  4  5  6  7  8
#      9 10 11 12 13 14 15
#     16 17 18 19 20 21 22
#     23 24 25 26 27 28 ..
#     
#     February               March                  
#     Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   
#                        1                      1   
#      2  3  4  5  6  7  8    2  3  4  5  6  7  8   
#      9 10 11 12 13 14 15    9 10 11 12 13 14 15   
#     16 17 18 19 20 21 22   16 17 18 19 20 21 22   
#     23 24 25 26 27 28      23 24 25 26 27 28 29   
