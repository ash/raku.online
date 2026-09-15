#!/usr/bin/env rakupp
# Locale::Dates — Asking for a locale
# https://raku.online/modules/locale-dates/#asking-for-a-locale
#
# Install what it needs, then run it:
#     rakupp install Locale::Dates
#     rakupp 02-indexing.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Locale::Dates;

my $d  = Date.new(2026, 3, 15);
my $de = Locale::Dates.new('DE');
say 'date            : ', $d, ' (Date.day-of-week = ', $d.day-of-week, ')';
say 'German weekday  : ', $de.weekdays[$d.day-of-week];
say 'German month    : ', $de.months[$d.month];
say '';
say 'that is why the tables are padded: month 3 really is index 3.';

# Output:
#     date            : 2026-03-15 (Date.day-of-week = 7)
#     German weekday  : Sontag
#     German month    : März
#     
#     that is why the tables are padded: month 3 really is index 3.
