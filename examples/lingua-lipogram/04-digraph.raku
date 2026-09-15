#!/usr/bin/env rakupp
# Lingua::Lipogram — The one thing to know
# https://raku.online/modules/lingua-lipogram/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::Lipogram
#     rakupp 04-digraph.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Lipogram;

say '<ch> is a ', <ch>.WHAT.^name, ', <ch ap> is a ', <ch ap>.WHAT.^name;
say '';
say 'lipogram("the cap", <ch>)      = ', lipogram('the cap', <ch>),
    '   <- forbids "c" and "h" SEPARATELY, and both are present';
say 'lipogram("the cap", ("ch",))   = ', lipogram('the cap', ('ch',)),
    '   <- forbids the SUBSTRING "ch", which is absent';
say '';
say 'so a one-element angle list silently switches you from "no digraph"';
say 'to "neither of these two letters". Write ("ch",) or ["ch"].';

# Output:
#     <ch> is a Str, <ch ap> is a List
#     
#     lipogram("the cap", <ch>)      = False   <- forbids "c" and "h" SEPARATELY, and both are present
#     lipogram("the cap", ("ch",))   = True   <- forbids the SUBSTRING "ch", which is absent
#     
#     so a one-element angle list silently switches you from "no digraph"
#     to "neither of these two letters". Write ("ch",) or ["ch"].
