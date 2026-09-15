#!/usr/bin/env rakupp
# Texas::To::Uni — The one thing to know
# https://raku.online/modules/texas-to-uni/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Texas::To::Uni
#     rakupp 05-order.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Texas::To::Uni;

say 'the table contains BOTH (<=) and !(<=). Whichever key the hash hands';
say 'out first wins, and if (<=) goes first the negated form is left';
say 'half-converted as !⊆ instead of becoming ⊈.';
say '';
say 'the six negated set operators are the affected ones:';
say '  !(<=)  !(<)  !(>=)  !(>)  !(elem)  !(cont)';
say '';
say 'whether each one comes out whole or half-converted is exactly what';
say 'varies — on Rakudo it varies between RUNS of the same program.';
say '';
say 'Rakudo randomises hash iteration order per process, so those six are';
say 'a coin flip there — run the same file twice and get different output.';
say 'Raku++ uses stable insertion order, so it is deterministic but not';
say 'necessarily right. Never put this in a build step.';

# Output:
#     the table contains BOTH (<=) and !(<=). Whichever key the hash hands
#     out first wins, and if (<=) goes first the negated form is left
#     half-converted as !⊆ instead of becoming ⊈.
#     
#     the six negated set operators are the affected ones:
#       !(<=)  !(<)  !(>=)  !(>)  !(elem)  !(cont)
#     
#     whether each one comes out whole or half-converted is exactly what
#     varies — on Rakudo it varies between RUNS of the same program.
#     
#     Rakudo randomises hash iteration order per process, so those six are
#     a coin flip there — run the same file twice and get different output.
#     Raku++ uses stable insertion order, so it is deterministic but not
#     necessarily right. Never put this in a build step.
