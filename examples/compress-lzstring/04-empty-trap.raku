#!/usr/bin/env rakupp
# Compress::LZString — The one thing to know
# https://raku.online/modules/compress-lzstring/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Compress::LZString
#     rakupp 04-empty-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Compress::LZString;

say 'lz-compress-base64("")        : ', lz-compress-base64('').raku;
say 'lz-decompress-base64("Q===")  : ', lz-decompress-base64('Q===').raku;
say '  — so the codec is symmetric';
say '';
say 'but:';
say 'lz-decompress-base64("")      : ', lz-decompress-base64('').raku;
say 'lz-decompress-uri("")         : ', lz-decompress-uri('').raku;
say 'lz-decompress(Buf[uint16])    : ', lz-decompress(Buf[uint16]).raku;

# Output:
#     lz-compress-base64("")        : "Q==="
#     lz-decompress-base64("Q===")  : ""
#       — so the codec is symmetric
#     
#     but:
#     lz-decompress-base64("")      : Str
#     lz-decompress-uri("")         : Str
#     lz-decompress(Buf[uint16])    : ""
