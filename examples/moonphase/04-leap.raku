#!/usr/bin/env rakupp
# Moonphase — Where the two engines differ
# https://raku.online/modules/moonphase/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Moonphase
#     rakupp 04-leap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Moonphase;

my $dt = DateTime.new(2017, 8, 21, 18, 26, 0);
say 'DateTime.posix.Int is leap-second free on both engines:';
say '  ', $dt.posix.Int, ' -> ', moonphase($dt.posix.Int).round(0.000001);
say '';
say 'Instant arithmetic is not. `+$dt` and `now` route through the';
say 'leap-second table, which Raku++ pins at 10 seconds for every date';
say 'and Rakudo tracks properly (32 s in 1999, 37 s since 2017).';
say '';
say 'Always feed this module .posix.Int, never an Instant.';

# Output:
#     DateTime.posix.Int is leap-second free on both engines:
#       1503339960 -> -0.000162
#     
#     Instant arithmetic is not. `+$dt` and `now` route through the
#     leap-second table, which Raku++ pins at 10 seconds for every date
#     and Rakudo tracks properly (32 s in 1999, 37 s since 2017).
#     
#     Always feed this module .posix.Int, never an Instant.
