#!/usr/bin/env rakupp
# Date::Calendar::MayaAztec — A day under every cycle
# https://raku.online/modules/date-calendar-mayaaztec/#a-day-under-every-cycle
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::MayaAztec
#     rakupp 01-cycles.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Maya;
use Date::Calendar::Aztec;

my $d = Date.new(2020, 6, 20);
my $m = Date::Calendar::Maya.new-from-date($d);

say 'gregorian   : ', $d;
say 'long count  : ', $m.long-count;
say '  haab      : ', $m.haab,    '   (month ', $m.month, ', day ', $m.day, ')';
say '  tzolkin   : ', $m.tzolkin;
say '  doy       : ', $m.day-of-year;
say '  epoch JDN : ', $m.epoch;
say '  strftime  : ', $m.strftime('%Y %A %B');
say '';
my $a = Date::Calendar::Aztec.new-from-date($d);
say 'aztec       : ', $a.gist;
say '  xiuh      : ', $a.xiuhpohualli;
say '  tonal     : ', $a.tonalpohualli;
say '  bearer    : ', $a.year-bearer;
say '';
say 'round trips : ', ($m.to-date == $d) && ($a.to-date == $d);

# Output:
#     gregorian   : 2020-06-20
#     long count  : 13.0.7.10.18
#       haab      : 1 Tzec   (month 5, day 1)
#       tzolkin   : 12 Etznab
#       doy       : 81
#       epoch JDN : 584283
#       strftime  : 9 Caban Etznab Tzec
#     
#     aztec       : 20-13 12-18
#       xiuh      : 20 Teotleco
#       tonal     : 12 Tecpatl
#       bearer    : 8 Tecpatl
#     
#     round trips : True
