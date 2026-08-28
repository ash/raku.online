#!/usr/bin/env rakupp
# JSON::Fast — `:immutable` — a result nobody can edit under you
# https://raku.online/modules/json-fast/#immutable-a-result-nobody-can-edit-under-you
#
# Install what it needs, then run it:
#     rakupp install JSON::Fast
#     rakupp 06-immutable.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Fast;

my $d = from-json('{"a":[1,2]}', :immutable);
say $d.^name;
say $d<a>.^name;
say (try { $d<a>[0] = 9; 'assigned' }) // 'refused';

# Output:
#     Map
#     List
#     refused
