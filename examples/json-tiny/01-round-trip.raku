#!/usr/bin/env rakupp
# JSON::Tiny — What it is for
# https://raku.online/modules/json-tiny/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install JSON::Tiny
#     rakupp 01-round-trip.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Tiny;

my $config = from-json('{"name":"raku","stars":4.5,"tags":["fast","fun"],"beta":false,"next":null}');
say $config<name>;
say $config<stars> * 2;
say $config<tags>[1];
say $config<beta>.^name;
say $config<next>.defined;
say to-json(['a', 'b', 'c']);

# Output:
#     raku
#     9
#     fun
#     Bool
#     False
#     [ "a", "b", "c" ]
