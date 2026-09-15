#!/usr/bin/env rakupp
# Mortgage — The class
# https://raku.online/modules/mortgage/#the-class
#
# Install what it needs, then run it:
#     rakupp install Mortgage
#     rakupp 04-class.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Mortgage;

my $c = rate-monthly(4.8);
my $m = Mortgage.new(
    currency       => 'EUR',
    bank           => 'BANK',
    loan-left      => 300_000,
    interest_rate  => $c,
    mortages       => 360,
    mortage        => calculate-payment($c, 360, 300_000),
    total_interest => 0,
    total_cost     => 0,
);
$m.add(Mortgage::AnnualCostConst.new(from => 1, to => 360, value => 10));
$m.calc;
print $m.gist;
say '';
say 'note the four extra constructor arguments. `calc` reads $!mortage,';
say '$!total_interest and $!total_cost before it ever writes them, and';
say 'none of the three has a default — so the documented three-argument';
say 'construction leaves them as Numeric type objects and the run is';
say 'silently wrong (Raku++) or dies in `gist` (Rakudo). Seed all four.';
say '';
say 'calc is DESTRUCTIVE and not idempotent — a second call resumes from';
say 'the mutated balance rather than restarting. There is no reset.';
say '';
say 'the three concrete cost classes are AnnualCostPercentage (balance x';
say 'rate), AnnualCostMort (payment x rate) and AnnualCostConst (a fixed';
say 'value). The base AnnualCost.get is a `!!!` stub.';

# Output:
#     BANK
#     Mortgage 1574 EUR
#     Balance: 0 EUR
#     Basic interests: 266638.58 EUR
#     Other costs: 3600 EUR
#     Total cost: 270238.58
#     Type used for cost (Int)
#     Type used for calculation (Num)
#     note the four extra constructor arguments. `calc` reads $!mortage,
#     $!total_interest and $!total_cost before it ever writes them, and
#     none of the three has a default — so the documented three-argument
#     construction leaves them as Numeric type objects and the run is
#     silently wrong (Raku++) or dies in `gist` (Rakudo). Seed all four.
#     
#     calc is DESTRUCTIVE and not idempotent — a second call resumes from
#     the mutated balance rather than restarting. There is no reset.
#     
#     the three concrete cost classes are AnnualCostPercentage (balance x
#     rate), AnnualCostMort (payment x rate) and AnnualCostConst (a fixed
#     value). The base AnnualCost.get is a `!!!` stub.
