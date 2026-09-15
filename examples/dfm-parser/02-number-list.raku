#!/usr/bin/env rakupp
# DFM::Parser — The one thing to know
# https://raku.online/modules/dfm-parser/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install DFM::Parser
#     rakupp 02-number-list.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DFM::Parser;

for '(1 2)', '(1)', '()', "('a' 'b')" -> $v {
    my $m = DFM::Parser.parse($v, rule => 'component-value');
    say sprintf('  component-value %-10s -> %s', $v.raku, $m.defined ?? 'MATCH' !! 'no match');
}
say '';
say 'number-list is a `rule` whose body is <number>*, and `number` is a';
say '`token` — so nothing eats the whitespace BETWEEN repetitions. A';
say 'rule`s implicit <.ws> sits after the quantified atom, not inside it.';
say '';
say 'string-list survives only because `string` is itself a rule and';
say 'swallows its own trailing space.';
say '';
say 'any real .dfm containing a Left = (0 0 100 100) fails outright, and';
say 'you get Nil, not a diagnostic.';

# Output:
#       component-value "(1 2)"    -> no match
#       component-value "(1)"      -> MATCH
#       component-value "()"       -> MATCH
#       component-value "('a' 'b')" -> MATCH
#     
#     number-list is a `rule` whose body is <number>*, and `number` is a
#     `token` — so nothing eats the whitespace BETWEEN repetitions. A
#     rule`s implicit <.ws> sits after the quantified atom, not inside it.
#     
#     string-list survives only because `string` is itself a rule and
#     swallows its own trailing space.
#     
#     any real .dfm containing a Left = (0 0 100 100) fails outright, and
#     you get Nil, not a diagnostic.
