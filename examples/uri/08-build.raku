#!/usr/bin/env rakupp
# URI — Building one
# https://raku.online/modules/uri/#building-one
#
# Install what it needs, then run it:
#     rakupp install URI
#     rakupp 08-build.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use URI;

my $u = URI.new('https://example.com/');
$u.path('/api/v2/things');
$u.query('page=2&per=50');
say ~$u;
say $u.path-query;

# Output:
#     https://example.com/api/v2/things?page=2&per=50
#     /api/v2/things?page=2&per=50
