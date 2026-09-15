#!/usr/bin/env rakupp
# Mortgage — The one thing to know
# https://raku.online/modules/mortgage/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Mortgage
#     rakupp 03-rate-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Mortgage;

my ($L, $n) = 300_000, 360;
for 'rate-monthly(4.8)'          => rate-monthly(4.8),
    'rate-monthly(percent(4.8))' => rate-monthly(percent(4.8)) -> $p {
    say sprintf('  %-28s = %-10s -> payment %s',
                $p.key, $p.value, calculate-payment($p.value, $n, $L).round(0.01));
}
say '';
say 'percent and rate-monthly look like a matched pair and must never be';
say 'composed. rate-monthly is `annual percent / 1200`, nothing else.';

# Output:
#       rate-monthly(4.8)            = 0.004      -> payment 1574
#       rate-monthly(percent(4.8))   = 0.00004    -> payment 839.36
#     
#     percent and rate-monthly look like a matched pair and must never be
#     composed. rate-monthly is `annual percent / 1200`, nothing else.
