#!/usr/bin/env rakupp
# Date::Easter — The invariants
# https://raku.online/modules/date-easter/#the-invariants
#
# Install what it needs, then run it:
#     rakupp install Date::Easter
#     rakupp 02-invariants.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Easter;

my ($bad-dow, $bad-range, $min, $max) = 0, 0, 'zz-zz', '';
for 1583 .. 2200 -> $y {
    my $e = Easter($y);
    $bad-dow++ unless $e.day-of-week == 7;
    my $md = $e.Str.substr(5);
    $bad-range++ unless '03-22' le $md le '04-25';
    $min = $md if $md lt $min;
    $max = $md if $md gt $max;
}
say 'years checked   : ', 2200 - 1583 + 1;
say 'non-Sundays     : ', $bad-dow;
say 'out of 03-22..04-25 : ', $bad-range;
say 'earliest seen   : ', $min;
say 'latest seen     : ', $max;

# Output:
#     years checked   : 618
#     non-Sundays     : 0
#     out of 03-22..04-25 : 0
#     earliest seen   : 03-22
#     latest seen     : 04-25
