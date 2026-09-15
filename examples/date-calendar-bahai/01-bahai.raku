#!/usr/bin/env rakupp
# Date::Calendar::Bahai — Converting a date
# https://raku.online/modules/date-calendar-bahai/#converting-a-date
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Bahai
#     rakupp 01-bahai.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Bahai;

my $g = Date.new('2026-09-14');
my $b = Date::Calendar::Bahai.new-from-date($g);

say "gregorian in  : $g";
say 'gist          : ', $b.gist;
say 'year/mon/day  : ', $b.year, ' / ', $b.month, ' / ', $b.day;
say 'month-name    : ', $b.month-name, '   abbr ', $b.month-abbr;
say 'day-name      : ', $b.day-name, '   abbr ', $b.day-abbr;
say 'day-of-week   : ', $b.day-of-week, '   day-of-year ', $b.day-of-year;
say 'major-cycle   : ', $b.major-cycle, '   cycle ', $b.cycle, '   cycle-year ', $b.cycle-year;
say 'cycle-year-nm : ', $b.cycle-year-name;
say 'is-leap       : ', $b.is-leap;
say 'locale        : ', $b.locale;
say 'strftime      : ', $b.strftime('%Y-%m-%d %A %B');
say '';
say 'round trip    : ', $b.to-date, '   exact : ', $b.to-date == $g;

# Output:
#     gregorian in  : 2026-09-14
#     gist          : 0183-10-07
#     year/mon/day  : 183 / 10 / 7
#     month-name    : 'Izzat   abbr Izz
#     day-name      : Kamál   abbr Kam
#     day-of-week   : 3   day-of-year 178
#     major-cycle   : 1   cycle 10   cycle-year 12
#     cycle-year-nm : Javáb
#     is-leap       : False
#     locale        : ar
#     strftime      : 0183-10-07 Kamál 'Izzat
#     
#     round trip    : 2026-09-14   exact : True
