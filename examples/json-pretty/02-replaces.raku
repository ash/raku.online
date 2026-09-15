#!/usr/bin/env rakupp
# JSON::Pretty — The one thing to know
# https://raku.online/modules/json-pretty/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install JSON::Pretty
#     rakupp 02-replaces.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Pretty;

say &to-json.name;
say &from-json.name;

say (try to-json({ a => 1 }, :sorted-keys)) // 'sorted-keys: refused';
say (try to-json({ a => 1 }, :!pretty))     // 'pretty: refused';

my $point = class { has $.x; has $.y }.new(x => 1, y => 2);
say (try to-json($point)) // 'an object: refused';

# Output:
#     pretty-json
#     from-json
#     sorted-keys: refused
#     pretty: refused
#     an object: refused
