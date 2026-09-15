#!/usr/bin/env rakupp
# Encode — The one thing to know
# https://raku.online/modules/encode/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Encode
#     rakupp 02-no-encode.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Encode;

say Encode::decode('latin2', Buf[uint8].new(0xE6));
say (try { ::('&Encode::encode') ~~ Callable }) // False;
say (try { ::('&Encode::decode') ~~ Callable }) // False;

my $blob = 'café'.encode('latin-1');
say $blob.^name;
say Encode::decode('latin1', Buf[uint8].new($blob.list));

# Output:
#     ć
#     False
#     True
#     Blob[uint8]
#     café
