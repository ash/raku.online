#!/usr/bin/env rakupp
# Locale::Dates — Asking for a locale
# https://raku.online/modules/locale-dates/#asking-for-a-locale
#
# Install what it needs, then run it:
#     rakupp install Locale::Dates
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Locale::Dates;

say 'known locales : ', Locale::Dates.known-locales.sort.join(' ');
say '';
my $en = Locale::Dates.new('EN');
say 'code          : ', $en.code;
say 'weekdays      : ', $en.weekdays.elems, ' entries -> ', $en.weekdays.join(' ');
say 'months        : ', $en.months.elems, ' entries -> ', $en.months.join(' ');
say 'abbr-weekdays : ', $en.abbreviated-weekdays.join(' ');
say 'am / pm       : ', $en.am, ' / ', $en.pm;
say 'AM / PM       : ', $en.AM, ' / ', $en.PM;
say '';
say 'date format   : ', $en.date-representation;
say 'time format   : ', $en.time-representation;

# Output:
#     known locales : BG DE EN FR NL PT RU
#     
#     code          : EN
#     weekdays      : 8 entries -> Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday
#     months        : 13 entries -> ? January February March April May June July August September October November December
#     abbr-weekdays : Sun Mon Tue Wed Thu Fri Sat Sun
#     am / pm       : am / pm
#     AM / PM       : AM / PM
#     
#     date format   : %a %b %e %Y
#     time format   : %T
