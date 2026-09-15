#!/usr/bin/env rakupp
# Number::Bytes::Human — The class
# https://raku.online/modules/number-bytes-human/#the-class
#
# Install what it needs, then run it:
#     rakupp install Number::Bytes::Human
#     rakupp 03-class.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Number::Bytes::Human;

say 'no import tag needed for the methods:';
say '  .format(1048576) = ', Number::Bytes::Human.format(1048576);
say "  .parse('1M')     = ", Number::Bytes::Human.parse('1M');

# Output:
#     no import tag needed for the methods:
#       .format(1048576) = 1M
#       .parse('1M')     = 1048576
