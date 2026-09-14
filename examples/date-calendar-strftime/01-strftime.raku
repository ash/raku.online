#!/usr/bin/env rakupp
# Date::Calendar::Strftime — On a core Date
# https://raku.online/modules/date-calendar-strftime/#on-a-core-date
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Strftime
#     rakupp 01-strftime.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Strftime;

my $d = Date.new('2026-09-14') does Date::Calendar::Strftime;
say $d.strftime('%Y-%m-%d is day %j, ISO week %V of %G, weekday %u');
say $d.strftime('%F | %e | %-d | %05j | %%');
say $d.strftime('%A %d %B');

# Output:
#     2026-09-14 is day 257, ISO week 38 of 2026, weekday 1
#     2026-09-14 | 14 | 14 | 00257 | %
#     %A 14 %B
