#!/usr/bin/env rakupp
# Operator::feq — Precedence and chaining
# https://raku.online/modules/operator-feq/#precedence-and-chaining
#
# Install what it needs, then run it:
#     rakupp install Operator::feq
#     rakupp 04-precedence.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Operator::feq;

say 'the operator carries no precedence trait, so it takes the DEFAULT for';
say 'a new infix — additive, the same as `+`:';
say '  "abcdefghi" ~ "j" feq "abcdefghik"';
say '  parses as   "abcdefghi" ~ ("j" feq "abcdefghik")';
say '  and yields  ', ('abcdefghi' ~ ('j' feq 'abcdefghik')).raku;
say '';
say 'so parenthesise when you mix it with anything:';
say '  ("abcdefghi" ~ "j") feq "abcdefghik" = ',
    (('abcdefghi' ~ 'j') feq 'abcdefghik');
say '';
say 'and despite `is assoc<none>`, chaining is not rejected — it compiles';
say 'and silently compares a Bool against a string. Compare two things.';

# Output:
#     the operator carries no precedence trait, so it takes the DEFAULT for
#     a new infix — additive, the same as `+`:
#       "abcdefghi" ~ "j" feq "abcdefghik"
#       parses as   "abcdefghi" ~ ("j" feq "abcdefghik")
#       and yields  "abcdefghiFalse"
#     
#     so parenthesise when you mix it with anything:
#       ("abcdefghi" ~ "j") feq "abcdefghik" = True
#     
#     and despite `is assoc<none>`, chaining is not rejected — it compiles
#     and silently compares a Bool against a string. Compare two things.
