#!/usr/bin/env rakupp
# JSON::Fast — Writing: `to-json` and its three adverbs
# https://raku.online/ecosystem/json-fast/#writing-to-json-and-its-three-adverbs
#
# Install what it needs, then run it:
#     rakupp install JSON::Fast
#     rakupp 04-spacing.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Fast;

print to-json({ a => 1, b => [2, 3] }, :sorted-keys, :spacing(4));

# Output:
#     {
#         "a": 1,
#         "b": [
#             2,
#             3
#         ]
#     }
