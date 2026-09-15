#!/usr/bin/env rakupp
# Date::Christian::Advent — Where the two engines differ
# https://raku.online/modules/date-christian-advent/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Date::Christian::Advent
#     rakupp 03-untyped.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Christian::Advent;

for '2025', 2025.0, 2025.5, 0 -> $y {
    my $r = try Advent-Sunday($y);
    say sprintf('Advent-Sunday(%-8s) -> %s', $y.raku, $r.defined ?? $r.Str !! 'threw');
}

# Output:
#     Advent-Sunday("2025"  ) -> 2025-11-30
#     Advent-Sunday(2025.0  ) -> 2025-11-30
#     Advent-Sunday(2025.5  ) -> 2025-11-30
#     Advent-Sunday(0       ) -> 0000-12-03
