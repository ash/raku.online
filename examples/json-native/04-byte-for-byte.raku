#!/usr/bin/env rakupp
# JSON::Native — Byte for byte, quirks included
# https://raku.online/modules/json-native/#byte-for-byte-quirks-included
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 04-byte-for-byte.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Native;

my $value = ["back\bspace", "𝄞", 2.5];
say to-json($value, :!pretty);
say from-json(to-json($value))[1] eq "𝄞";
say to-json([]).raku;

# Output:
#     ["back\u0008space","\uD834\uDD1E",2.5]
#     True
#     "[\n]"
