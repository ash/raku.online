#!/usr/bin/env rakupp
# Compress::LZString — Round trips
# https://raku.online/modules/compress-lzstring/#round-trips
#
# Install what it needs, then run it:
#     rakupp install Compress::LZString
#     rakupp 01-roundtrip.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Compress::LZString;

my $text = 'the rain in spain falls mainly on the plain; ' x 6;
say 'input : ', $text.chars, ' chars';
say '';

my $raw = lz-compress($text);
say 'lz-compress        : ', $raw.elems, ' 16-bit units, ', $raw.bytes, ' bytes';
say '  round trip       : ', lz-decompress($raw) eq $text;

my $bytes = lz-compress-bytes($text);
say 'lz-compress-bytes  : ', $bytes.bytes, ' bytes';
say '  round trip       : ', lz-decompress-bytes($bytes) eq $text;

my $b64 = lz-compress-base64($text);
say 'lz-compress-base64 : ', $b64.chars, ' chars';
say '  round trip       : ', lz-decompress-base64($b64) eq $text;

my $uri = lz-compress-uri($text);
say 'lz-compress-uri    : ', $uri.chars, ' chars';
say '  round trip       : ', lz-decompress-uri($uri) eq $text;

my $u16 = lz-compress-utf16($text);
say 'lz-compress-utf16  : ', $u16.elems, ' code points';
say '  round trip       : ', lz-decompress-utf16($u16) eq $text;

# Output:
#     input : 270 chars
#     
#     lz-compress        : 53 16-bit units, 106 bytes
#       round trip       : True
#     lz-compress-bytes  : 106 bytes
#       round trip       : True
#     lz-compress-base64 : 144 chars
#       round trip       : True
#     lz-compress-uri    : 142 chars
#       round trip       : True
#     lz-compress-utf16  : 58 code points
#       round trip       : True
