#!/usr/bin/env rakupp
# JSON::Native — The types you get back are JSON::Fast's
# https://raku.online/modules/json-native/#the-types-you-get-back-are-jsonfasts
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 03-types.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Native;

my %n = from-json('{"i":42,"r":0.1,"e":2e3,"big":123456789012345678901234567890}');
say %n<i>.^name, ' ', %n<i>;
say %n<r>.^name, ' ', %n<r> + 0.2 == 0.3;
say %n<e>.^name;
say %n<big> + 1;

# Output:
#     Int 42
#     Rat True
#     Num
#     123456789012345678901234567891
