#!/usr/bin/env rakupp
# Lazy::Static — The one thing to know
# https://raku.online/modules/lazy-static/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lazy::Static
#     rakupp 03-failure-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lazy::Static;

my &value = lazy-static -> { die 'generator failed' };

my $first = (try value()) // "call 1 threw: {$!.message}";
say $first;

my $p = start { value() };
await Promise.anyof($p, Promise.in(3));
say 'call 2 status after three seconds: ', $p.status;
exit 0;

# Output:
#     call 1 threw: generator failed
#     call 2 status after three seconds: Planned
