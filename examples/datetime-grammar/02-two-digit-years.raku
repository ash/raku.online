#!/usr/bin/env rakupp
# DateTime::Grammar — The one thing to know
# https://raku.online/modules/datetime-grammar/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install DateTime::Grammar
#     rakupp 02-two-digit-years.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Grammar;

say datetime-interpret('Monday, 14-Sep-26 00:00:00 GMT');
say datetime-interpret('14-Sep-99');
say datetime-interpret('14-Sep-00');
say datetime-interpret('Fri, 14 Sep 2026 00:00:00 GMT');
say Date.new('2026-09-14').day-of-week;

# Output:
#     0026-09-14T00:00:00Z
#     0099-09-14T00:00:00Z
#     0000-09-14T00:00:00Z
#     2026-09-14T00:00:00Z
#     1
