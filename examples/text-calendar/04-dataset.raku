#!/usr/bin/env rakupp
# Text::Calendar — Reading the data instead of the grid
# https://raku.online/modules/text-calendar/#reading-the-data-instead-of-the-grid
#
# Install what it needs, then run it:
#     rakupp install Text::Calendar
#     rakupp 04-dataset.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Calendar;

my @weeks = calendar-month-dataset(2026, 2);
say 'weeks in February 2026 : ', @weeks.elems;
for @weeks.kv -> $i, %w {
    say "  week $i: ", <Mo Tu We Th Fr Sa Su>.map({ %w{$_}.trim || '.' }).join(' ');
}

# Output:
#     weeks in February 2026 : 5
#       week 0: . . . . . . 1
#       week 1: 2 3 4 5 6 7 8
#       week 2: 9 10 11 12 13 14 15
#       week 3: 16 17 18 19 20 21 22
#       week 4: 23 24 25 26 27 28 .
