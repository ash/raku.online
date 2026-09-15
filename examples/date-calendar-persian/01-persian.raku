#!/usr/bin/env rakupp
# Date::Calendar::Persian — Converting a date
# https://raku.online/modules/date-calendar-persian/#converting-a-date
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Persian
#     rakupp 01-persian.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Persian;

my $g = Date.new('2026-09-14');
my $p = Date::Calendar::Persian.new-from-date($g);

say "gregorian in : $g";
say 'gist         : ', $p.gist;
say 'year/mon/day : ', $p.year, ' / ', $p.month, ' / ', $p.day;
say 'month-name   : ', $p.month-name, '   abbr ', $p.month-abbr;
say 'day-name     : ', $p.day-name, '   abbr ', $p.day-abbr;
say 'day-of-week  : ', $p.day-of-week, '   day-of-year ', $p.day-of-year;
say 'week-number  : ', $p.week-number, '   week-year ', $p.week-year;
say 'daycount     : ', $p.daycount;
say 'strftime     : ', $p.strftime('%Y-%m-%d %A %B');
say '';
say 'round trip   : ', $p.to-date, '   exact : ', $p.to-date == $g;

# Output:
#     gregorian in : 2026-09-14
#     gist         : 1405-06-23
#     year/mon/day : 1405 / 6 / 23
#     month-name   : Shahrivar   abbr Sha
#     day-name     : Do shanbe   abbr 2sh
#     day-of-week  : 3   day-of-year 178
#     week-number  : 26   week-year 1405
#     daycount     : 61297
#     strftime     : 1405-06-23 Do shanbe Shahrivar
#     
#     round trip   : 2026-09-14   exact : True
