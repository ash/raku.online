#!/usr/bin/env rakupp
# JSON::Fast — Writing: `to-json` and its three adverbs
# https://raku.online/modules/json-fast/#writing-to-json-and-its-three-adverbs
#
# Install what it needs, then run it:
#     rakupp install JSON::Fast
#     rakupp 03-pretty.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Fast;

print to-json({ name => 'raku', tags => <fast fun> }, :sorted-keys);

# Output:
#     {
#       "name": "raku",
#       "tags": [
#         "fast",
#         "fun"
#       ]
#     }
