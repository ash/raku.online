#!/usr/bin/env rakupp
# URI — The query is not a Hash
# https://raku.online/ecosystem/uri/#the-query-is-not-a-hash
#
# Install what it needs, then run it:
#     rakupp install URI
#     rakupp 06-query.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use URI;

my $u = URI.new('https://example.com/search?q=raku&page=2&tag=fast&tag=fun');
say $u.query;
say $u.query.^name;
say $u.query<q>;
say $u.query<page>;
say $u.query<tag>.join(',');
say $u.query.keys.sort.squish.join(' ');

# Output:
#     q=raku&page=2&tag=fast&tag=fun
#     URI::Query
#     (raku)
#     (2)
#     fast,fun
#     page q tag
