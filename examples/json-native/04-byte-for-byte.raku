#!/usr/bin/env rakupp
# JSON::Native — Byte for byte, checked against the original
# https://raku.online/modules/json-native/#byte-for-byte-checked-against-the-original
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 04-byte-for-byte.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Native;

my &reference = do { use JSON::Fast; &to-json };

my $value = ["back\bspace", "𝄞", 2.5];
say to-json($value, :!pretty);
say to-json($value, :!pretty) eq reference($value, :!pretty);
say from-json(to-json($value))[1] eq "𝄞";

# Output:
#     ["back\u0008space","\uD834\uDD1E",2.5]
#     True
#     True
