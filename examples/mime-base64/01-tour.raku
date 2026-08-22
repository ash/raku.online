#!/usr/bin/env rakupp
# MIME::Base64 — What it is for
# https://raku.online/ecosystem/mime-base64/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install MIME::Base64
#     rakupp 01-tour.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use MIME::Base64;

say MIME::Base64.encode-str('Raku++ makes JSON go');
say MIME::Base64.decode-str('UmFrdSsrIG1ha2VzIEpTT04gZ28=');

# Output:
#     UmFrdSsrIG1ha2VzIEpTT04gZ28=
#     Raku++ makes JSON go
