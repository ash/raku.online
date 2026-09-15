#!/usr/bin/env rakupp
# JSON::Unmarshal — Documents into objects
# https://raku.online/modules/json-unmarshal/#documents-into-objects
#
# Install what it needs, then run it:
#     rakupp install JSON::Unmarshal
#     rakupp 02-type-checks.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Unmarshal;

class Person { has Str $.name; has Int $.born }

say (try unmarshal('{"born":"not a number"}', Person)) // $!.^name;
say unmarshal('{"name":"Ada","unexpected":1}', Person).name;
say (try unmarshal('{"unexpected":1}', Person, :die)) // $!.^name;
say unmarshal('{}', Person).born.defined;

# Output:
#     JSON::Unmarshal::X::CannotUnmarshal
#     Ada
#     JSON::Unmarshal::X::UnusedKeys
#     False
