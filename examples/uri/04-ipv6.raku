#!/usr/bin/env rakupp
# URI — The parts of an authority
# https://raku.online/ecosystem/uri/#the-parts-of-an-authority
#
# Install what it needs, then run it:
#     rakupp install URI
#     rakupp 04-ipv6.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use URI;

my $u = URI.new('https://[2001:db8::1]:8080/p');
say $u.host;
say $u.port;

# Output:
#     [2001:db8::1]
#     8080
