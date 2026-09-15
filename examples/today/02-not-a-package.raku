#!/usr/bin/env rakupp
# Today — What it is not
# https://raku.online/modules/today/#what-it-is-not
#
# Install what it needs, then run it:
#     rakupp install Today
#     rakupp 02-not-a-package.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Today;

say 'what the module publishes : one term, evaluating to ', today.WHAT.^name;
say '';
say '`Today` itself is not a type, not a class and not a package —';
say 'naming it is an error on both engines (at compile time on Rakudo,';
say 'at run time on Raku++). The distribution name and the symbol it';
say 'installs have nothing to do with each other.';

# Output:
#     what the module publishes : one term, evaluating to Date
#     
#     `Today` itself is not a type, not a class and not a package —
#     naming it is an error on both engines (at compile time on Rakudo,
#     at run time on Raku++). The distribution name and the symbol it
#     installs have nothing to do with each other.
