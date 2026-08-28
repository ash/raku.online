#!/usr/bin/env rakupp
# App::Rakus — The response head is data too
# https://raku.online/modules/app-rakus/#the-response-head-is-data-too
#
# Install what it needs, then run it:
#     rakupp install App::Rakus
#     rakupp 05-response-head.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use App::Rakus;

my $head = head-for(301, 'text/html; charset=utf-8', 0, ('Location' => '/docs/'));
.say for $head.lines;

# Output:
#     HTTP/1.1 301 Moved Permanently
#     Content-Type: text/html; charset=utf-8
#     Content-Length: 0
#     Location: /docs/
#     Server: rakus
#     Connection: close
