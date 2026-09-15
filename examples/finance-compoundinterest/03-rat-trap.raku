#!/usr/bin/env rakupp
# Finance::CompoundInterest — The one thing to know
# https://raku.online/modules/finance-compoundinterest/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Finance::CompoundInterest
#     rakupp 03-rat-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Finance::CompoundInterest;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-58s %s', $label, $! ?? 'refused' !! 'ok -> ' ~ $r.round(0.0001));
}

attempt 'compound_interest(1000, 1/20, 12, 10)  — Int and Rat',
        { compound_interest(1000, 1/20, 12, 10) };
attempt 'compound_interest(1000e0, 0.05e0, 12e0, 10e0)  — all Num',
        { compound_interest(1000e0, 0.05e0, 12e0, 10e0) };
attempt 'ciwp_payment_size(13954.01, 0.005e0, 60)  — Num rate',
        { ciwp_payment_size(13954.01, 0.005e0, 60) };
attempt 'ciwp_payment_period(13954.01, 0.005e0, 200)  — Num rate',
        { ciwp_payment_period(13954.01, 0.005e0, 200) };
attempt 'compound_interest_with_payments(200, 0.005, 60)  — Int and Rat',
        { compound_interest_with_payments(200, 0.005, 60) };
attempt 'compound_interest_with_payments(200, 0.005e0, 60)  — Num rate',
        { compound_interest_with_payments(200, 0.005e0, 60) };
attempt 'compound_interest_with_payments(200, 1, 60)  — Int rate',
        { compound_interest_with_payments(200, 1, 60) };

# Output:
#     compound_interest(1000, 1/20, 12, 10)  — Int and Rat       ok -> 1647.0095
#     compound_interest(1000e0, 0.05e0, 12e0, 10e0)  — all Num   ok -> 1647.0095
#     ciwp_payment_size(13954.01, 0.005e0, 60)  — Num rate       ok -> 200.0001
#     ciwp_payment_period(13954.01, 0.005e0, 200)  — Num rate    ok -> 60
#     compound_interest_with_payments(200, 0.005, 60)  — Int and Rat ok -> 13954.0061
#     compound_interest_with_payments(200, 0.005e0, 60)  — Num rate refused
#     compound_interest_with_payments(200, 1, 60)  — Int rate    refused
