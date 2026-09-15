#!/usr/bin/env rakupp
# Base64::Native — The one thing to know
# https://raku.online/modules/base64-native/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Base64::Native
#     rakupp 04-buffer-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Base64::Native;

my $in = 'Hello, Raku!';           # 12 bytes -> 16 base64 characters

say 'default buffer : ', base64-encode($in, :str).raku;
say 'buffer of 8    : ', base64-encode($in.encode, buf8.allocate(8)).decode.raku;
say 'buffer of 4    : ', base64-encode($in.encode, buf8.allocate(4)).decode.raku;
say 'buffer of 64   : ', base64-encode($in.encode, buf8.allocate(64)).decode.raku;

# Output:
#     default buffer : "SGVsbG8sIFJha3Uh"
#     buffer of 8    : "SGVsbG8s"
#     buffer of 4    : "SGVs"
#     buffer of 64   : "SGVsbG8sIFJha3Uh\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
