#!/usr/bin/env rakupp
# Date::Calendar::Hijri — Converting a date
# https://raku.online/modules/date-calendar-hijri/#converting-a-date
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Hijri
#     rakupp 01-hijri.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Hijri;

my $g = Date.new('2026-09-14');
my $h = Date::Calendar::Hijri.new-from-date($g);

say "gregorian in : $g";
say 'gist         : ', $h.gist;
say 'year/mon/day : ', $h.year, ' / ', $h.month, ' / ', $h.day;
say 'month-name   : ', $h.month-name, '   abbr ', $h.month-abbr;
say 'day-name     : ', $h.day-name, '   abbr ', $h.day-abbr;
say 'day-of-week  : ', $h.day-of-week, '   day-of-year ', $h.day-of-year;
say 'week-number  : ', $h.week-number, '   week-year ', $h.week-year;
say 'daycount     : ', $h.daycount;
say 'strftime     : ', $h.strftime('%Y-%m-%d %A %B');
say '';
say 'round trip   : ', $h.to-date, '   exact : ', $h.to-date == $g;

# Output:
#     gregorian in : 2026-09-14
#     gist         : 1448-04-01
#     year/mon/day : 1448 / 4 / 1
#     month-name   : Rabi` al-Thaani   abbr R.T
#     day-name     : Yaum al-Ithnain   abbr Ith
#     day-of-week  : 2   day-of-year 90
#     week-number  : 14   week-year 1448
#     daycount     : 61297
#     strftime     : 1448-04-01 Yaum al-Ithnain Rabi` al-Thaani
#     
#     round trip   : 2026-09-14   exact : True
