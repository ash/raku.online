#!/usr/bin/env rakupp
# DateTime::Math — The operators
# https://raku.online/modules/datetime-math/#the-operators
#
# Install what it needs, then run it:
#     rakupp install DateTime::Math
#     rakupp 02-operators.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Math;

my $dt = DateTime.new(2025, 12, 31, 23, 59, 30, :timezone(0));
say "base      : $dt";
say '+ 30 s    : ', $dt + 30;
say '+ 60 s    : ', $dt + 60;
say '60 + $dt  : ', 60 + $dt;
say '- 90 s    : ', $dt - 90;
say '+ one day : ', $dt + to-seconds(1, 'd');

# Output:
#     base      : 2025-12-31T23:59:30Z
#     + 30 s    : 2026-01-01T00:00:00Z
#     + 60 s    : 2026-01-01T00:00:30Z
#     60 + $dt  : 2026-01-01T00:00:30Z
#     - 90 s    : 2025-12-31T23:58:00Z
#     + one day : 2026-01-01T23:59:30Z
