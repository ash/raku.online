#!/usr/bin/env rakupp
# URI::Encode — Building a query string
# https://raku.online/modules/uri-encode/#building-a-query-string
#
# Install what it needs, then run it:
#     rakupp install URI::Encode
#     rakupp 02-query-string.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use URI::Encode;

my @params = department => 'R&D', q => 'raku modules', page => 2;
my $query = @params.map({ .key ~ '=' ~ uri_encode_component(.value.Str) }).join('&');
say 'https://example.com/search?' ~ $query;

# Output:
#     https://example.com/search?department=R%26D&q=raku%20modules&page=2
