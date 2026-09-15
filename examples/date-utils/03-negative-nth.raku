#!/usr/bin/env rakupp
# Date::Utils — The one thing to know
# https://raku.online/modules/date-utils/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Date::Utils
#     rakupp 03-negative-nth.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Utils;

my $base = Date.new('2026-09-14');
for 2, 1, 0, -1, -2 -> $n {
    say $n, ' -> ', nth-dow-after-date(:date($base), :nth($n), :dow(7));
}
say nth-dow-after-date(:date($base), :nth(10), :dow(7));

# Output:
#     2 -> 2026-09-27
#     1 -> 2026-09-20
#     0 -> 2026-11-22
#     -1 -> 2026-11-22
#     -2 -> 2026-11-22
#     2026-11-22
