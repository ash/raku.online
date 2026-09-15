#!/usr/bin/env rakupp
# Date::Calendar::Persian — The one thing to know
# https://raku.online/modules/date-calendar-persian/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Persian
#     rakupp 04-variants-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Persian;
use Date::Calendar::Persian::Astronomical;

my @disagree = (Date.new('2024-06-01') .. Date.new('2026-09-01')).grep({
    Date::Calendar::Persian.new-from-date($_).gist
      ne Date::Calendar::Persian::Astronomical.new-from-date($_).gist
});

say 'days where the two classes disagree : ', @disagree.elems;
say '  first : ', @disagree[0];
say '  last  : ', @disagree[*-1];
say '  one contiguous run : ', @disagree[*-1] - @disagree[0] + 1 == @disagree.elems;
say '';
my $g = Date.new('2025-06-15');
say "inside that window, $g:";
say '  arithmetic   : ', Date::Calendar::Persian.new-from-date($g).gist;
say '  astronomical : ', Date::Calendar::Persian::Astronomical.new-from-date($g).gist;

# Output:
#     days where the two classes disagree : 366
#       first : 2025-03-20
#       last  : 2026-03-20
#       one contiguous run : True
#     
#     inside that window, 2025-06-15:
#       arithmetic   : 1404-03-26
#       astronomical : 1404-03-25
