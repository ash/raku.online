#!/usr/bin/env rakupp
# Mortgage — Where the two engines differ
# https://raku.online/modules/mortgage/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Mortgage
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Mortgage;

# the constructor shape that behaves the same on both engines
sub mortgage($principal, $annual-percent, $months) {
    my $c = rate-monthly($annual-percent);
    Mortgage.new(
        currency       => 'EUR',
        bank           => 'BANK',
        loan-left      => $principal,
        interest_rate  => $c,
        mortages       => $months,
        mortage        => calculate-payment($c, $months, $principal),
        total_interest => 0,
        total_cost     => 0,
    )
}

my $m = mortgage(300_000, 4.8, 360);
$m.add(Mortgage::AnnualCostConst.new(from => 1, to => 360, value => 10));
say 'monthly : ', $m.mortage.round(0.01);
$m.calc;
say 'balance : ', $m.loan-left.round(0.01);
say 'interest: ', $m.total_interest.round(0.01);
say 'cost    : ', $m.total_cost.round(0.01);
say '';
say 'without the three zero seeds, `say $mortgage` raises "No such method';
say 'round for invocant of type Numeric" on Rakudo and prints 0 on Raku++ —';
say 'and `say $m` is the first thing anyone does.';

# Output:
#     monthly : 1574
#     balance : 0
#     interest: 266638.58
#     cost    : 3600
#     
#     without the three zero seeds, `say $mortgage` raises "No such method
#     round for invocant of type Numeric" on Rakudo and prints 0 on Raku++ —
#     and `say $m` is the first thing anyone does.
