#!/usr/bin/env rakupp
# DFM::Parser — Where the two engines differ
# https://raku.online/modules/dfm-parser/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install DFM::Parser
#     rakupp 05-dset.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DFM::Parser;

say 'the rule matches on its own:';
say '  :rule<dset> on "[a, b]" -> ',
    DFM::Parser.parse('[a, b]', rule => 'dset').defined ?? 'MATCH' !! 'no match';
say '';
say 'reaching it through component-value is engine-dependent — Raku++`s';
say 'longest-token alternation cannot select a branch containing a';
say '%-separated quantifier, so a form with a BorderIcons line parses on';
say 'Rakudo and fails on Raku++.';
say '';
say 'and the rule will not accept internal spaces on either engine:';
for '[a,b]', '[a, b]', '[ a , b ]' -> $v {
    say sprintf('  %-12s -> %s', $v.raku,
                DFM::Parser.parse($v, rule => 'dset').defined ?? 'MATCH' !! 'no match');
}

# Output:
#     the rule matches on its own:
#       :rule<dset> on "[a, b]" -> MATCH
#     
#     reaching it through component-value is engine-dependent — Raku++`s
#     longest-token alternation cannot select a branch containing a
#     %-separated quantifier, so a form with a BorderIcons line parses on
#     Rakudo and fails on Raku++.
#     
#     and the rule will not accept internal spaces on either engine:
#       "[a,b]"      -> MATCH
#       "[a, b]"     -> MATCH
#       "[ a , b ]"  -> no match
