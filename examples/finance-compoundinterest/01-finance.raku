#!/usr/bin/env rakupp
# Finance::CompoundInterest — The four formulas
# https://raku.online/modules/finance-compoundinterest/#the-four-formulas
#
# Install what it needs, then run it:
#     rakupp install Finance::CompoundInterest
#     rakupp 01-finance.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Finance::CompoundInterest;

say '1000 at 5% compounded monthly for 10 years:';
say '  ', compound_interest(1000.0, 0.05, 12.0, 10.0).round(0.01);
say '';
say '200 a month for 60 months at 0.5% a month:';
my $fv = compound_interest_with_payments(200.0, 0.005, 60.0);
say '  ', $fv.round(0.01);
say '';
say 'the two inverses of that same stream:';
say '  periods needed for 13954.01 : ', ciwp_payment_period(13954.01, 0.005, 200.0).round(0.0001);
say '  payment size for 13954.01   : ', ciwp_payment_size(13954.01, 0.005, 60.0).round(0.01);

# Output:
#     1000 at 5% compounded monthly for 10 years:
#       1647.01
#     
#     200 a month for 60 months at 0.5% a month:
#       13954.01
#     
#     the two inverses of that same stream:
#       periods needed for 13954.01 : 60
#       payment size for 13954.01   : 200
