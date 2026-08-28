#!/usr/bin/env rakupp
# URI — The parts of an authority
# https://raku.online/modules/uri/#the-parts-of-an-authority
#
# Install what it needs, then run it:
#     rakupp install URI
#     rakupp 02-authority.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use URI;

my $u = URI.new('https://user:pw@example.com:8443/a/b/c.html');
say $u.authority;
say $u.userinfo;
say $u.host;
say $u.port;

# Output:
#     user:pw@example.com:8443
#     user:pw
#     example.com
#     8443
