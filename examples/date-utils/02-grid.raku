#!/usr/bin/env rakupp
# Date::Utils — Laying out a grid
# https://raku.online/modules/date-utils/#laying-out-a-grid
#
# Install what it needs, then run it:
#     rakupp install Date::Utils
#     rakupp 02-grid.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Utils;

my $first = Date.new('2026-09-01');
say dow-name($first.day-of-week);

for 7, 1 -> $starts-on {
    say dow-name($starts-on), ' calendar:';
    say '  columns  ', days-of-week($starts-on).map({ dow-name($_).substr(0, 3) }).join(' ');
    say '  1 Sep in column ', day-index-in-week($first.day-of-week, :cal-first-dow($starts-on));
    say '  week 1 holds ', days-in-week1($first.day-of-week, :cal-first-dow($starts-on)), ' days';
    say '  rows needed  ', weeks-in-month($first, :cal-first-dow($starts-on));
}

# Output:
#     Tuesday
#     Sunday calendar:
#       columns  Sun Mon Tue Wed Thu Fri Sat
#       1 Sep in column 2
#       week 1 holds 5 days
#       rows needed  5
#     Monday calendar:
#       columns  Mon Tue Wed Thu Fri Sat Sun
#       1 Sep in column 1
#       week 1 holds 6 days
#       rows needed  5
