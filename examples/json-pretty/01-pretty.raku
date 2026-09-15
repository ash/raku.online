#!/usr/bin/env rakupp
# JSON::Pretty — Formatted output
# https://raku.online/modules/json-pretty/#formatted-output
#
# Install what it needs, then run it:
#     rakupp install JSON::Pretty
#     rakupp 01-pretty.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Pretty;

say to-json({ outer => [ 1, { inner => 'v' }, [ ] ] });
say to-json([1, 2]);
say to-json(42).raku;
say to-json('hi').raku;
say to-json(Any).raku;
say to-json({}).raku;
say to-json([]).raku;

say from-json('{"a":[1,2,{"b":null}]}')<a>[2]<b>.raku;

# Output:
#     {
#       "outer" : [
#         1,
#         {
#           "inner" : "v"
#         },
#         [ ]
#       ]
#     }
#     [
#       1,
#       2
#     ]
#     "42"
#     "\"hi\""
#     "null"
#     "\{ }"
#     "[ ]"
#     Any
