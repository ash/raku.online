#!/usr/bin/env rakupp
# Text::Calendar — The one thing to know
# https://raku.online/modules/text-calendar/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::Calendar
#     rakupp 05-title-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Calendar;

say 'plain title for 2024-02  : ', calendar-month-block(2024, 2).lines[0].raku;
say 'plain title for 2026-02  : ', calendar-month-block(2026, 2).lines[0].raku;
say 'transposed title         : ', calendar-month-block(2026, 2, :transposed).lines[0].raku;
say '';
say 'and the two grids are quite different:';
say '  2024-02 last row : ', calendar-month-block(2024, 2).lines[*-1].trim.raku;
say '  2026-02 last row : ', calendar-month-block(2026, 2).lines[*-1].trim.raku;

# Output:
#     plain title for 2024-02  : "February            "
#     plain title for 2026-02  : "February            "
#     transposed title         : "    February 2026"
#     
#     and the two grids are quite different:
#       2024-02 last row : "26 27 28 29"
#       2026-02 last row : "23 24 25 26 27 28"
