#!/usr/bin/env rakupp
# Today — Where the two engines differ
# https://raku.online/modules/today/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Today
#     rakupp 04-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Today;

# the portable spelling, if you need a callable: wrap the term yourself
my &right-now = { today };
say 'a wrapper block   : ', right-now() ~~ Date;
say 'mapped over a list: ', (^3).map({ today.later(:days($_)) }).map(*.day-of-week).elems;
say '';
say 'without the `use`, the term is not there — it is properly lexical';
say 'on both engines, so importing it does not leak into your callers.';

# Output:
#     a wrapper block   : True
#     mapped over a list: 3
#     
#     without the `use`, the term is not there — it is properly lexical
#     on both engines, so importing it does not leak into your callers.
