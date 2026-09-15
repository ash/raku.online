#!/usr/bin/env rakupp
# Date::Calendar::Armenian — Converting
# https://raku.online/modules/date-calendar-armenian/#converting
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Armenian
#     rakupp 01-convert.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Armenian;

my $g = Date.new(2025, 4, 3);
my $a = Date::Calendar::Armenian.new-from-date($g);

say 'gregorian   : ', $g;
say 'armenian    : ', $a.gist;
say '  month     : ', $a.month, '  ', $a.month-name, ' (', $a.month-abbr, ')';
say '  day-name  : ', $a.day-name;
say '  month-day : ', $a.month-day-name;
say '  doy       : ', $a.day-of-year;
say '  daycount  : ', $a.daycount, '   (Date.daycount = ', $g.daycount, ')';
say '  strftime  : ', $a.strftime('%Y-%m-%d %A %B %Oj');
say '';
say 'back to Date: ', $a.to-date, '  same? ', $a.to-date == $g;

# Output:
#     gregorian   : 2025-04-03
#     armenian    : 1474-09-17
#       month     : 9  ahekan-i (Ahe)
#       day-name  : hingšabatʿi
#       month-day : asak
#       doy       : 257
#       daycount  : 60768   (Date.daycount = 60768)
#       strftime  : 1474-09-17 hingšabatʿi ahekan-i 257
#     
#     back to Date: 2025-04-03  same? True
