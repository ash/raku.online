#!/usr/bin/env rakupp
# JSON::Tiny — Numbers come back typed
# https://raku.online/modules/json-tiny/#numbers-come-back-typed
#
# Install what it needs, then run it:
#     rakupp install JSON::Tiny
#     rakupp 02-number-types.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Tiny;

my $data = from-json('{"count": 42, "ratio": 0.6, "big": 1e10}');
say $data<count>.^name;
say $data<ratio>.^name;
say $data<ratio> == 3/5;
say $data<big>.^name;

# Output:
#     Int
#     Rat
#     True
#     Num
