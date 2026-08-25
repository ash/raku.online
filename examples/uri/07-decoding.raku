#!/usr/bin/env rakupp
# URI — The query is not a Hash
# https://raku.online/modules/uri/#the-query-is-not-a-hash
#
# Install what it needs, then run it:
#     rakupp install URI
#     rakupp 07-decoding.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use URI;

my $u = URI.new('https://example.com/a%20b/c?q=one%20two');
say $u.path;
say $u.query<q>;

# Output:
#     /a%20b/c
#     (one two)
