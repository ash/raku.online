#!/usr/bin/env rakupp
# Date::Calendar::Armenian — Where the two engines differ
# https://raku.online/modules/date-calendar-armenian/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Armenian
#     rakupp 04-dow.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Armenian;

my $g = Date.new(2025, 4, 6);   # a Sunday
my $a = Date::Calendar::Armenian.new-from-date($g);
say 'gregorian 2025-04-06 is a Sunday';
say '  Date.day-of-week      = ', $g.day-of-week, '   (Monday = 1)';
say '  Armenian day-of-week  = ', $a.day-of-week, '   (kiraki = 1)';
say '';
say 'the two are a rotation apart. Indexing a weekday table with the';
say 'wrong one is silently off by six.';

# Output:
#     gregorian 2025-04-06 is a Sunday
#       Date.day-of-week      = 7   (Monday = 1)
#       Armenian day-of-week  = 1   (kiraki = 1)
#     
#     the two are a rotation apart. Indexing a weekday table with the
#     wrong one is silently off by six.
