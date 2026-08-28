#!/usr/bin/env rakupp
# JSON::Native — What it is for
# https://raku.online/modules/json-native/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 01-tour.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Native;

my $data = from-json('{"name":"raku","versions":[6,"d"],"fast":true,"pi":3.14}');
say $data<name>;
say $data<versions>[1];
say $data<fast>.^name;
say $data<pi> * 100;
say to-json($data, :!pretty, :sorted-keys);

# Output:
#     raku
#     d
#     Bool
#     314
#     {"fast":true,"name":"raku","pi":3.14,"versions":[6,"d"]}
