#!/usr/bin/env rakupp
# Lazy::Static — Making something lazy
# https://raku.online/modules/lazy-static/#making-something-lazy
#
# Install what it needs, then run it:
#     rakupp install Lazy::Static
#     rakupp 01-lazy.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lazy::Static;

my $calls = 0;
my &answer = lazy-static -> { $calls++; 6 * 7 };

say 'generator calls before first use : ', $calls;
say 'call 1 -> ', answer();
say 'call 2 -> ', answer();
say 'call 3 -> ', answer();
say 'generator calls after three uses : ', $calls;

# Output:
#     generator calls before first use : 0
#     call 1 -> 42
#     call 2 -> 42
#     call 3 -> 42
#     generator calls after three uses : 1
