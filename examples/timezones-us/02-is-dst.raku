#!/usr/bin/env rakupp
# Timezones::US — Asking whether a moment is in DST
# https://raku.online/modules/timezones-us/#asking-whether-a-moment-is-in-dst
#
# Install what it needs, then run it:
#     rakupp install Timezones::US
#     rakupp 02-is-dst.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Timezones::US;

for DateTime.new(2025, 7, 4, 12, 0, 0),
    DateTime.new(2025, 1, 4, 12, 0, 0),
    DateTime.new(2025, 3, 9,  2, 0, 0),
    DateTime.new(2025, 11, 2, 2, 0, 0) -> $t {
    say sprintf('%s -> %s', $t, is-dst(localtime => $t));
}
say '';
say 'the boundary is CLOSED at both ends: the November instant is the';
say 'moment DST has just ended, and it still answers True.';

# Output:
#     2025-07-04T12:00:00Z -> True
#     2025-01-04T12:00:00Z -> False
#     2025-03-09T02:00:00Z -> True
#     2025-11-02T02:00:00Z -> True
#     
#     the boundary is CLOSED at both ends: the November instant is the
#     moment DST has just ended, and it still answers True.
