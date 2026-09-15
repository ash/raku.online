#!/usr/bin/env rakupp
# Timezones::US — The transition instants
# https://raku.online/modules/timezones-us/#the-transition-instants
#
# Install what it needs, then run it:
#     rakupp install Timezones::US
#     rakupp 01-transitions.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Timezones::US;

for 2007, 2020, 2024, 2025, 2026 -> $y {
    say sprintf('%d  begin %s   end %s', $y, begin-dst($y), end-dst($y));
}
say '';
say 'those match the published second-Sunday-in-March /';
say 'first-Sunday-in-November rule, including the years where';
say '1 November is itself a Sunday (2020, 2026).';

# Output:
#     2007  begin 2007-03-11T02:00:00Z   end 2007-11-04T02:00:00Z
#     2020  begin 2020-03-08T02:00:00Z   end 2020-11-01T02:00:00Z
#     2024  begin 2024-03-10T02:00:00Z   end 2024-11-03T02:00:00Z
#     2025  begin 2025-03-09T02:00:00Z   end 2025-11-02T02:00:00Z
#     2026  begin 2026-03-08T02:00:00Z   end 2026-11-01T02:00:00Z
#     
#     those match the published second-Sunday-in-March /
#     first-Sunday-in-November rule, including the years where
#     1 November is itself a Sunday (2020, 2026).
