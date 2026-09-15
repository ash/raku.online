#!/usr/bin/env rakupp
# Date::Utils — Holidays from their rules
# https://raku.online/modules/date-utils/#holidays-from-their-rules
#
# Install what it needs, then run it:
#     rakupp install Date::Utils
#     rakupp 01-rules.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Utils;

say nth-dow-in-month(:year(2026), :month(9),  :nth(1),  :dow(1));
say nth-dow-in-month(:year(2026), :month(1),  :nth(3),  :dow(1));
say nth-dow-in-month(:year(2026), :month(11), :nth(4),  :dow(4));
say nth-dow-in-month(:year(2026), :month(5),  :nth(-1), :dow(1));

my $base = Date.new('2026-09-14');
say dow-name($base.day-of-week);
say nth-dow-after-date(:date($base), :nth(1), :dow(5));
say nth-dow-after-date(:date($base), :nth(2), :dow(5));

# Output:
#     2026-09-07
#     2026-01-19
#     2026-11-26
#     2026-05-25
#     Monday
#     2026-09-18
#     2026-09-25
