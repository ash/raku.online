#!/usr/bin/env rakupp
# Math::Polynomial::Chebyshev — Where the two engines differ
# https://raku.online/modules/math-polynomial-chebyshev/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Math::Polynomial::Chebyshev
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Polynomial::Chebyshev;

say 'keep these out of your own code around this module:';
say '';
say '  chebyshev-t(-1, 0.5) — the dispatch failure message differs:';
say '    Raku++ omits the argument types entirely, Rakudo names them.';
say '    Catch X::Multi::NoMatch / X::TypeCheck, never match the text.';
say '';
say '  .map on the Block that chebyshev-t(4) returns — Raku++ has no';
say '    Block.map. Call the block, then map:';
say '    ', (0, 0.5, 1).map({ chebyshev-t(4).($_) }).map(*.round(0.0001)).join(', ');
say '';
say '  .denominator on a Num — 1 on Raku++, a method-not-found on Rakudo.';
say '    Test the TYPE first:';
for 10, 80 -> $k {
    my $v = chebyshev-t($k, 1/3);
    say sprintf('    k=%-3d exact ? %s', $k, ($v ~~ Rat).so);
}

# Output:
#     keep these out of your own code around this module:
#     
#       chebyshev-t(-1, 0.5) — the dispatch failure message differs:
#         Raku++ omits the argument types entirely, Rakudo names them.
#         Catch X::Multi::NoMatch / X::TypeCheck, never match the text.
#     
#       .map on the Block that chebyshev-t(4) returns — Raku++ has no
#         Block.map. Call the block, then map:
#         1, -0.5, 1
#     
#       .denominator on a Num — 1 on Raku++, a method-not-found on Rakudo.
#         Test the TYPE first:
#         k=10  exact ? True
#         k=80  exact ? False
