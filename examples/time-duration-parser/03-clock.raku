#!/usr/bin/env rakupp
# Time::Duration::Parser — The clock form
# https://raku.online/modules/time-duration-parser/#the-clock-form
#
# Install what it needs, then run it:
#     rakupp install Time::Duration::Parser
#     rakupp 03-clock.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Time::Duration::Parser;

for '1:30', '1:30:15', '0:01', '100:00', '1:70', '0:99:99' -> $s {
    my $v = duration-to-seconds($s);
    say sprintf('%-10s -> %s', "'$s'", $v.defined ?? $v.Int !! 'not parsed');
}

# Output:
#     '1:30'     -> 5400
#     '1:30:15'  -> 5415
#     '0:01'     -> 60
#     '100:00'   -> 360000
#     '1:70'     -> 7800
#     '0:99:99'  -> 6039
