#!/usr/bin/env rakupp
# Finance::CompoundInterest — A case you can verify by hand
# https://raku.online/modules/finance-compoundinterest/#a-case-you-can-verify-by-hand
#
# Install what it needs, then run it:
#     rakupp install Finance::CompoundInterest
#     rakupp 02-simple.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Finance::CompoundInterest;

say '1000 at 10% compounded once a year for 3 years:';
say '  computed : ', compound_interest(1000.0, 0.10, 1.0, 3.0).round(0.01);
say '  by hand  : ', (1000 * 1.1 ** 3).round(0.01);
say '';
say 'return type : ', compound_interest(1000.0, 0.10, 1.0, 3.0).^name;

# Output:
#     1000 at 10% compounded once a year for 3 years:
#       computed : 1331
#       by hand  : 1331
#     
#     return type : Num
