#!/usr/bin/env rakupp
# HTTP::Status — The predicates, and a log line
# https://raku.online/modules/http-status/#the-predicates-and-a-log-line
#
# Install what it needs, then run it:
#     rakupp install HTTP::Status
#     rakupp 02-predicates.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTTP::Status;

say is-client-error(404), ' ', is-server-error(404);

for 301, 404, 503 -> $code {
    my $st = HTTP::Status($code);
    say $code ~ ' ' ~ $st ~ ' — ' ~ $st.type;
}

# Output:
#     True False
#     301 Moved Permanently — Redirection
#     404 Not Found — Client Error
#     503 Service Unavailable — Server Error
