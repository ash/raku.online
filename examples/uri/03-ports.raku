#!/usr/bin/env rakupp
# URI — The parts of an authority
# https://raku.online/ecosystem/uri/#the-parts-of-an-authority
#
# Install what it needs, then run it:
#     rakupp install URI
#     rakupp 03-ports.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use URI;

say URI.new('http://example.com/').port;
say URI.new('https://example.com/').port;
say URI.new('http://example.com/').default-port;

# Output:
#     80
#     443
#     80
