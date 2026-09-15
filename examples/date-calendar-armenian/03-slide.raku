#!/usr/bin/env rakupp
# Date::Calendar::Armenian — The one thing to know
# https://raku.online/modules/date-calendar-armenian/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Armenian
#     rakupp 03-slide.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Armenian;

for 1474 .. 1482 -> $y {
    my $a = Date::Calendar::Armenian.new(year => $y, month => 9, day => 17);
    say sprintf('  arm %d-09-17  ->  %s', $y, $a.to-date);
}
say '';
say 'a birthday or anniversary computed once and cached is wrong';
say 'within four years. Recompute it, or store the Gregorian date.';

# Output:
#       arm 1474-09-17  ->  2025-04-03
#       arm 1475-09-17  ->  2026-04-03
#       arm 1476-09-17  ->  2027-04-03
#       arm 1477-09-17  ->  2028-04-02
#       arm 1478-09-17  ->  2029-04-02
#       arm 1479-09-17  ->  2030-04-02
#       arm 1480-09-17  ->  2031-04-02
#       arm 1481-09-17  ->  2032-04-01
#       arm 1482-09-17  ->  2033-04-01
#     
#     a birthday or anniversary computed once and cached is wrong
#     within four years. Recompute it, or store the Gregorian date.
