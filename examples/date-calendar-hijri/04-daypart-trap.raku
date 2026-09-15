#!/usr/bin/env rakupp
# Date::Calendar::Hijri — The one thing to know
# https://raku.online/modules/date-calendar-hijri/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Hijri
#     rakupp 04-daypart-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Hijri;
use Date::Calendar::Strftime;

my $day = Date::Calendar::Hijri.new(year => 1448, month => 4, day => 2);
my $eve = Date::Calendar::Hijri.new(year => 1448, month => 4, day => 2,
                                    daypart => after-sunset());

say 'Hijri 1448-04-02 in daylight     -> ', $day.to-date;
say 'Hijri 1448-04-02 after sunset    -> ', $eve.to-date;
say 'the same Hijri date, a day apart : ', $day.to-date - $eve.to-date;
say '';
my $g = Date.new('2026-09-14');
say "Gregorian $g in daylight  -> ",
    Date::Calendar::Hijri.new-from-daycount($g.daycount, daypart => daylight()).gist;
say "Gregorian $g after sunset -> ",
    Date::Calendar::Hijri.new-from-daycount($g.daycount, daypart => after-sunset()).gist;

# Output:
#     Hijri 1448-04-02 in daylight     -> 2026-09-15
#     Hijri 1448-04-02 after sunset    -> 2026-09-14
#     the same Hijri date, a day apart : 1
#     
#     Gregorian 2026-09-14 in daylight  -> 1448-04-01
#     Gregorian 2026-09-14 after sunset -> 1448-04-02
