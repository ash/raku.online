#!/usr/bin/env rakupp
# JSON::Native — `:immutable`, and the import options
# https://raku.online/modules/json-native/#immutable-and-the-import-options
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 05-immutable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
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
