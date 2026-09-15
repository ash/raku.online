#!/usr/bin/env rakupp
# Base64::Native — Encoding and decoding
# https://raku.online/modules/base64-native/#encoding-and-decoding
#
# Install what it needs, then run it:
#     rakupp install Base64::Native
#     rakupp 01-b64.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Base64::Native;

say 'encode returns a buffer : ', base64-encode('Hello, Raku!').decode;
say 'with :str, a Str        : ', base64-encode('Hello, Raku!', :str).raku;
say 'decode gives bytes back : ',
    base64-decode(base64-encode('Hello, Raku!', :str)).decode.raku;
say '';
say 'padding:';
for '', 'a', 'ab', 'abc', 'abcd' -> $s {
    say sprintf('  %-6s (%d bytes) -> %s', $s.raku, $s.chars, base64-encode($s, :str).raku);
}

# Output:
#     encode returns a buffer : SGVsbG8sIFJha3Uh
#     with :str, a Str        : "SGVsbG8sIFJha3Uh"
#     decode gives bytes back : "Hello, Raku!"
#     
#     padding:
#       ""     (0 bytes) -> ""
#       "a"    (1 bytes) -> "YQ=="
#       "ab"   (2 bytes) -> "YWI="
#       "abc"  (3 bytes) -> "YWJj"
#       "abcd" (4 bytes) -> "YWJjZA=="
