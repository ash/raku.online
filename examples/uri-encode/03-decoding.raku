#!/usr/bin/env rakupp
# URI::Encode — Decoding, and the plus sign
# https://raku.online/modules/uri-encode/#decoding-and-the-plus-sign
#
# Install what it needs, then run it:
#     rakupp install URI::Encode
#     rakupp 03-decoding.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use URI::Encode;

say uri_decode('caf%C3%A9%20au%20lait');
say uri_decode('a+b%20c');
say uri_decode_component('100%25%20%2B%2020%25');

# Output:
#     café au lait
#     a+b c
#     100% + 20%
