#!/usr/bin/env rakupp
# URI::Encode — What it is for
# https://raku.online/modules/uri-encode/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install URI::Encode
#     rakupp 01-two-questions.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use URI::Encode;

my $url = 'https://example.com/search?q=café au lait&lang=fr';
say uri_encode($url);
say uri_encode_component('café au lait & more');

# Output:
#     https://example.com/search?q=caf%C3%A9%20au%20lait&lang=fr
#     caf%C3%A9%20au%20lait%20%26%20more
