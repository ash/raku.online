#!/usr/bin/env rakupp
# JSON::Pretty::Sorted — Writing JSON
# https://raku.online/modules/json-pretty-sorted/#writing-json
#
# Install what it needs, then run it:
#     rakupp install JSON::Pretty::Sorted
#     rakupp 01-write.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Pretty::Sorted;

my &bykey = { $^a.key cmp $^b.key };

my %data = zebra => 1, apple => 2, mango => 3, banana => 4;
say to-json(%data, sorter => &bykey);

# Output:
#     {
#       "apple" : 2,
#       "banana" : 4,
#       "mango" : 3,
#       "zebra" : 1
#     }
