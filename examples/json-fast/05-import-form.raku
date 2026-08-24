#!/usr/bin/env rakupp
# JSON::Fast — Writing: `to-json` and its three adverbs
# https://raku.online/ecosystem/json-fast/#writing-to-json-and-its-three-adverbs
#
# Install what it needs, then run it:
#     rakupp install JSON::Fast
#     rakupp 05-import-form.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Fast <immutable !pretty>;

my $d = from-json('{"a":1}');
say $d.^name;
say to-json({ a => 1 });

# Output:
#     Map
#     {"a":1}
