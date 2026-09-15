#!/usr/bin/env rakupp
# Text::Calendar — One month, and a year
# https://raku.online/modules/text-calendar/#one-month-and-a-year
#
# Install what it needs, then run it:
#     rakupp install Text::Calendar
#     rakupp 01-month.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Calendar;

say calendar-month-block(2026, 2);
say '';
say calendar-weekday-names().raku;
say calendar-month-names(:short).raku;

# Output:
#     February            
#     Mo Tu We Th Fr Sa Su
#                        1
#      2  3  4  5  6  7  8
#      9 10 11 12 13 14 15
#     16 17 18 19 20 21 22
#     23 24 25 26 27 28   
#     
#     ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
#     ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
