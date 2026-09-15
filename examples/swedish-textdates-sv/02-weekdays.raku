#!/usr/bin/env rakupp
# Swedish::TextDates_sv — Weekday names
# https://raku.online/modules/swedish-textdates-sv/#weekday-names
#
# Install what it needs, then run it:
#     rakupp install Swedish::TextDates_sv
#     rakupp 02-weekdays.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Swedish::TextDates_sv;

for 1 .. 7 -> $n {
    my $d = Day-Of-Week-Name_sv.new(day_of_week_number => $n);
    say sprintf('  %d  %-9s %s', $n, $d.get-day-name_sv, $d.get-day-name-short_sv);
}

# Output:
#       1  måndag    mån
#       2  tisdag    tis
#       3  onsdag    ons
#       4  torsdag   tors
#       5  fredag    fre
#       6  lördag    lör
#       7  söndag    sön
