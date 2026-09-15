#!/usr/bin/env rakupp
# JSON::Pretty::Sorted — Nested documents
# https://raku.online/modules/json-pretty-sorted/#nested-documents
#
# Install what it needs, then run it:
#     rakupp install JSON::Pretty::Sorted
#     rakupp 02-nested.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Pretty::Sorted;

my &bykey = { $^a.key cmp $^b.key };

my %nest = zebra => 1, apple => { zz => 1, aa => 2 }, mango => 3;
say to-json(%nest, sorter => &bykey);

# Output:
#     {
#       "apple" : {
#         "aa" : 2,
#         "zz" : 1
#       },
#       "mango" : 3,
#       "zebra" : 1
#     }
