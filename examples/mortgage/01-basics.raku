#!/usr/bin/env rakupp
# Mortgage — The formulas
# https://raku.online/modules/mortgage/#the-formulas
#
# Install what it needs, then run it:
#     rakupp install Mortgage
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Mortgage;

my $L = 300_000;
my $c = rate-monthly(4.8);       # the ANNUAL PERCENT, not a fraction
my $n = 360;

say 'percent(4.8)       = ', percent(4.8);
say 'rate-monthly(4.8)  = ', $c;
say 'basis-point(164)   = ', basis-point(164);
say '';
my $payment = calculate-payment($c, $n, $L);
say 'monthly payment    = ', $payment.round(0.01);
say '  closed form      = ', ($L * $c / (1 - (1 + $c) ** -$n)).round(0.01);
say '';
say 'remaining balance after p payments:';
for 0, 1, 180, 359, 360 -> $p {
    say sprintf('  p=%-4d %12.2f', $p, calculate-balance($c, $n, $L, $p));
}
say '';
say 'future value : ', calculate-fvalue(1000, 0.05, 10).round(0.0001);
say '  1000 * 1.05**10 = ', (1000 * 1.05 ** 10).round(0.0001);

# Output:
#     percent(4.8)       = 0.048
#     rate-monthly(4.8)  = 0.004
#     basis-point(164)   = 0.0164
#     
#     monthly payment    = 1574
#       closed form      = 1574
#     
#     remaining balance after p payments:
#       p=0       300000.00
#       p=1       299626.00
#       p=180     201687.21
#       p=359       1567.73
#       p=360          0.00
#     
#     future value : 1628.8946
#       1000 * 1.05**10 = 1628.8946
