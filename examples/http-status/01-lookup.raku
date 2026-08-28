#!/usr/bin/env rakupp
# HTTP::Status — What it is for
# https://raku.online/modules/http-status/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install HTTP::Status
#     rakupp 01-lookup.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTTP::Status;

my $s = HTTP::Status(418);
say $s.code, ' ', $s.title;
say $s.type;
say "and 404 reads as: {HTTP::Status(404)}";
say HTTP::Status(999) // 'unknown code';

# Output:
#     418 I'm a teapot
#     Client Error
#     and 404 reads as: Not Found
#     unknown code
