#!/usr/bin/env rakupp
# Date::Calendar::Armenian — The shape of the year
# https://raku.online/modules/date-calendar-armenian/#the-shape-of-the-year
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Armenian
#     rakupp 02-year.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Armenian;

say 'the epoch, 1 Nawasard 1:';
my $epoch = Date::Calendar::Armenian.new(year => 1, month => 1, day => 1);
say '  MJD ', $epoch.daycount, ' = ', $epoch.to-date;
say '';
say 'the thirteenth month holds exactly five days:';
for 5, 6 -> $d {
    my $r = try Date::Calendar::Armenian.new(year => 1474, month => 13, day => $d);
    say sprintf('  month 13 day %d -> %s', $d, $! ?? 'refused' !! $r.gist);
}
say '';
say 'and there is no year 0 — the day before the epoch cannot be built:';
my $r = try Date::Calendar::Armenian.new-from-date($epoch.to-date - 1);
say '  ', $! ?? 'refused' !! $r.gist;

# Output:
#     the epoch, 1 Nawasard 1:
#       MJD -477133 = 0552-07-13
#     
#     the thirteenth month holds exactly five days:
#       month 13 day 5 -> 1474-13-05
#       month 13 day 6 -> refused
#     
#     and there is no year 0 — the day before the epoch cannot be built:
#       refused
