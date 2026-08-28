#!/usr/bin/env rakupp
# HTTP::Status — Deeper than the title
# https://raku.online/modules/http-status/#deeper-than-the-title
#
# Install what it needs, then run it:
#     rakupp install HTTP::Status
#     rakupp 03-provenance.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTTP::Status;

my $s = HTTP::Status(451);
say $s.title;
say 'RFC ', $s.RFC;

say HTTP::Status(525).title;
say HTTP::Status(525).origin;

# Output:
#     Unavailable For Legal Reasons
#     RFC 7725
#     SSL Handshake Failed
#     Cloudflare
