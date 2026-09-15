#!/usr/bin/env rakupp
# Date::Calendar::Persian — Nowruz
# https://raku.online/modules/date-calendar-persian/#nowruz
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Persian
#     rakupp 02-nowruz.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Persian;

say 'the first day of each Persian year, in Gregorian terms:';
for 1403, 1404, 1405, 1406 -> $y {
    my $p = Date::Calendar::Persian.new(year => $y, month => 1, day => 1);
    say sprintf('  Persian %d-01-01 = %s', $y, $p.to-date);
}

# Output:
#     the first day of each Persian year, in Gregorian terms:
#       Persian 1403-01-01 = 2024-03-20
#       Persian 1404-01-01 = 2025-03-20
#       Persian 1405-01-01 = 2026-03-21
#       Persian 1406-01-01 = 2027-03-21
