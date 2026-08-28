#!/usr/bin/env rakupp
# Base64 — What it is for
# https://raku.online/modules/base64/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install Base64
#     rakupp 01-encode-decode.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Base64;

say encode-base64('Raku is fun!', :str);
say decode-base64('UmFrdSBpcyBmdW4h', :bin).decode;

# Output:
#     UmFrdSBpcyBmdW4h
#     Raku is fun!
