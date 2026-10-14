#!/usr/bin/env rakupp
# JSON::Native — `:immutable`, and the import options
# https://raku.online/modules/json-native/#immutable-and-the-import-options
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 06-import-options.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Native <!pretty sorted-keys>;

say to-json({ name => 'raku', tags => <fast exact>, note => Any });
say to-json({ name => 'raku' }, :pretty);

# Output:
#     {"name":"raku","note":null,"tags":["fast","exact"]}
#     {
#       "name": "raku"
#     }
