#!/usr/bin/env rakupp
# Sort::Naturally — Sorting naturally
# https://raku.online/modules/sort-naturally/#sorting-naturally
#
# Install what it needs, then run it:
#     rakupp install Sort::Naturally
#     rakupp 02-keys.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Sort::Naturally;

for '7', '007', 'a10' -> $s {
    say sprintf('  naturally(%-6s) = %s', $s.raku, naturally($s).raku);
}
say '';
say 'those keys contain NUL and low control characters by construction.';
say 'Never persist, log or round-trip them through anything line-based —';
say 'they are for sort and nothing else.';

# Output:
#       naturally("7"   ) = "0\x[1]7\07"
#       naturally("007" ) = "0\x[3]007\0007"
#       naturally("a10" ) = "a0\x[2]10\0a10"
#     
#     those keys contain NUL and low control characters by construction.
#     Never persist, log or round-trip them through anything line-based —
#     they are for sort and nothing else.
