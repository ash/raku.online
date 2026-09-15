#!/usr/bin/env rakupp
# DateTime::Math — The one thing to know
# https://raku.online/modules/datetime-math/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install DateTime::Math
#     rakupp 04-calendar-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Math;

say 'the units against each other:';
say '  1 year in months  : ', duration-from-to(1, 'y', 'M'), '   (not 12)';
say '  12 months in days : ', duration-from-to(12, 'M', 'd'), '   (not 365)';
say '';
my $a = DateTime.new(2024, 2, 28, 12, 0, 0, :timezone(0));   # a leap year
say "starting from $a:";
say '  + to-seconds(1, "y") : ', $a + to-seconds(1, 'y');
say '  core .later(:1year)  : ', $a.later(:1year);
say '';
say '  + to-seconds(1, "M") : ', $a + to-seconds(1, 'M');
say '  core .later(:1month) : ', $a.later(:1month);

# Output:
#     the units against each other:
#       1 year in months  : 12.166667   (not 12)
#       12 months in days : 360   (not 365)
#     
#     starting from 2024-02-28T12:00:00Z:
#       + to-seconds(1, "y") : 2025-02-27T12:00:00Z
#       core .later(:1year)  : 2025-02-28T12:00:00Z
#     
#       + to-seconds(1, "M") : 2024-03-29T12:00:00Z
#       core .later(:1month) : 2024-03-28T12:00:00Z
