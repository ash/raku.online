#!/usr/bin/env rakupp
# JSON::Marshal — The one thing to know
# https://raku.online/modules/json-marshal/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install JSON::Marshal
#     rakupp 03-pretty-default.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Marshal;

class Small { has Int $.n }

say marshal(Small.new(n => 1)).lines.elems, ' lines by default';
say marshal(Small.new(n => 1), :!pretty);
say marshal(Small.new(n => 1), :!pretty).chars, ' characters compact';

# Output:
#     3 lines by default
#     {"n":1}
#     7 characters compact
