#!/usr/bin/env rakupp
# Operator::feq — The rule
# https://raku.online/modules/operator-feq/#the-rule
#
# Install what it needs, then run it:
#     rakupp install Operator::feq
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Operator::feq;

for <abcdefghij abcdefghij>, <abcdefghij abcdefghik>,
    <abcdefghi abcdefghz>, <cat cat>, <cat cot>,
    <abcdefghij abcdefghji> -> ($a, $b) {
    say sprintf('  %-12s feq %-12s = %s', $a.raku, $b.raku, ($a feq $b));
}
say '';
say 'one typo in ten is 0.1, which is at the threshold, so it passes.';
say 'one typo in nine is over it, so it fails. A transposition scores 2,';
say 'not 1.';
say '';
say 'the consequence: for any string shorter than ten characters,';
say 'feq is exactly eq.';

# Output:
#       "abcdefghij" feq "abcdefghij" = True
#       "abcdefghij" feq "abcdefghik" = True
#       "abcdefghi"  feq "abcdefghz"  = False
#       "cat"        feq "cat"        = True
#       "cat"        feq "cot"        = False
#       "abcdefghij" feq "abcdefghji" = False
#     
#     one typo in ten is 0.1, which is at the threshold, so it passes.
#     one typo in nine is over it, so it fails. A transposition scores 2,
#     not 1.
#     
#     the consequence: for any string shorter than ten characters,
#     feq is exactly eq.
