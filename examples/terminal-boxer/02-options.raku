#!/usr/bin/env rakupp
# Terminal::Boxer — The named arguments
# https://raku.online/modules/terminal-boxer/#the-named-arguments
#
# Install what it needs, then run it:
#     rakupp install Terminal::Boxer
#     rakupp 02-options.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::Boxer;

print ss-box(:col(2), :cell(8), <alpha beta gamma delta>);
print ss-box(:col(2), :indent('>>>'), <ab cd ef gh>);
print ss-box(:col(2), :ch(2), <ab cd ef gh>);
print ss-box(:col(2), :f({ '[' ~ $^t ~ ']' }), <ab cd ef gh>);
print draw(:draw('=!/v\\>+<\\^/'), :col(2), :cw(3), :ch(1), <aa bb cc dd>);

# Output:
#     ┌────────┬────────┐
#     │  alpha │  beta  │
#     ├────────┼────────┤
#     │  gamma │  delta │
#     └────────┴────────┘
#     >>>┌──┬──┐
#     >>>│ab│cd│
#     >>>├──┼──┤
#     >>>│ef│gh│
#     >>>└──┴──┘
#     ┌──┬──┐
#     │ab│cd│
#     │  │  │
#     ├──┼──┤
#     │ef│gh│
#     │  │  │
#     └──┴──┘
#     ┌──┬──┐
#     │[ab]│[cd]│
#     ├──┼──┤
#     │[ef]│[gh]│
#     └──┴──┘
#     /===v===\
#     ! aa! bb!
#     >===+===<
#     ! cc! dd!
#     \===^===/
