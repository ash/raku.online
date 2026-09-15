#!/usr/bin/env rakupp
# Data::DPath6 — The one thing to know
# https://raku.online/modules/data-dpath6/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Data::DPath6
#     rakupp 02-not-there.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::DPath6;

for <dpath dpathi search query select> -> $m {
    say sprintf('  .^can(%-8s) : %d', $m.raku, Data::DPath6.^can($m).elems);
}
say '';
say 'there is no path language, no data selection, nothing. A green test';
say 'suite here is evidence of packaging, not of function.';
say '';
say 'that is worth stating plainly because the failure mode is quiet:';
say '`zef install Data::DPath6` succeeds, `use Data::DPath6` succeeds,';
say 'and the first call you actually wanted is a method-not-found.';

# Output:
#       .^can("dpath" ) : 0
#       .^can("dpathi") : 0
#       .^can("search") : 0
#       .^can("query" ) : 0
#       .^can("select") : 0
#     
#     there is no path language, no data selection, nothing. A green test
#     suite here is evidence of packaging, not of function.
#     
#     that is worth stating plainly because the failure mode is quiet:
#     `zef install Data::DPath6` succeeds, `use Data::DPath6` succeeds,
#     and the first call you actually wanted is a method-not-found.
