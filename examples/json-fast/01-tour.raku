#!/usr/bin/env rakupp
# JSON::Fast — What it is for
# https://raku.online/modules/json-fast/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install JSON::Fast
#     rakupp 01-tour.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Fast;

my %config = from-json('{"name":"raku","stars":3,"tags":["fast","fun"]}');
say %config<name>;
say %config<tags>.join(', ');
say to-json({ ok => True, count => 2 }, :sorted-keys, :!pretty);

# Output:
#     raku
#     fast, fun
#     {"count":2,"ok":true}
