#!/usr/bin/env rakupp
# Date::Calendar::Hijri — Day-of-week numbering
# https://raku.online/modules/date-calendar-hijri/#day-of-week-numbering
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Hijri
#     rakupp 03-dow.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Hijri;

my $g = Date.new('2026-09-14');     # a Monday
say "gregorian $g is a Monday";
say '  Raku Date.day-of-week  : ', $g.day-of-week;
say '  Hijri  .day-of-week    : ', Date::Calendar::Hijri.new-from-date($g).day-of-week;
say '  Hijri  .day-name       : ', Date::Calendar::Hijri.new-from-date($g).day-name;
say '';
say 'the Hijri week starts on Sunday and Raku counts from Monday,';
say 'so the same day has two different numbers.';

# Output:
#     gregorian 2026-09-14 is a Monday
#       Raku Date.day-of-week  : 1
#       Hijri  .day-of-week    : 2
#       Hijri  .day-name       : Yaum al-Ithnain
#     
#     the Hijri week starts on Sunday and Raku counts from Monday,
#     so the same day has two different numbers.
