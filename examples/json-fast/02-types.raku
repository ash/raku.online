#!/usr/bin/env rakupp
# JSON::Fast — Reading: the types you get back
# https://raku.online/ecosystem/json-fast/#reading-the-types-you-get-back
#
# Install what it needs, then run it:
#     rakupp install JSON::Fast
#     rakupp 02-types.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Fast;

my %n = from-json('{"i":42,"r":3.5,"e":1e3,"big":123456789012345678901234567890}');
say %n<i>.^name,   ' ', %n<i>;
say %n<r>.^name,   ' ', %n<r>;
say %n<e>.^name,   ' ', %n<e>;
say %n<big>.^name, ' ', %n<big>;

# Output:
#     Int 42
#     Rat 3.5
#     Num 1000
#     Int 123456789012345678901234567890
