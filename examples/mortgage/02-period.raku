#!/usr/bin/env rakupp
# Mortgage — The one thing to know
# https://raku.online/modules/mortgage/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Mortgage
#     rakupp 02-period.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Mortgage;

my ($L, $c, $n) = 300_000, rate-monthly(4.8), 360;
my $payment = calculate-payment($c, $n, $L);

say 'monthly payment                     : ', $payment.round(0.01);
say '';
say 'calculate-balance(c, n, L, 180)     : ',
    calculate-balance($c, $n, $L, 180).round(0.01), '   <- p = period number';
say 'calculate-balance(c, n, L, $payment): ',
    calculate-balance($c, $n, $L, $payment).round(0.01), '   <- p = the payment';
say '';
say 'that second line computes (1+c)**1574 and answers a NEGATIVE balance';
say 'over a hundred times the size of the loan, with no exception and no';
say 'warning. The proof that p is a period: p=0 returns the full loan and';
say 'p=n returns zero.';

# Output:
#     monthly payment                     : 1574
#     
#     calculate-balance(c, n, L, 180)     : 201687.21   <- p = period number
#     calculate-balance(c, n, L, $payment): -49686484.24   <- p = the payment
#     
#     that second line computes (1+c)**1574 and answers a NEGATIVE balance
#     over a hundred times the size of the loan, with no exception and no
#     warning. The proof that p is a period: p=0 returns the full loan and
#     p=n returns zero.
