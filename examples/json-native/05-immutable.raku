#!/usr/bin/env rakupp
# JSON::Native — `:immutable` is claimed; everything else is delegated
# https://raku.online/modules/json-native/#immutable-is-claimed-everything-else-is-delegated
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 05-immutable.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Native;

my $config = from-json('{"a":[1,2]}', :immutable);
say $config.^name;
say $config<a>.^name;
say (try { $config<a>[0] = 9; 'assigned' }) // 'refused';

# Output:
#     Map
#     List
#     refused
