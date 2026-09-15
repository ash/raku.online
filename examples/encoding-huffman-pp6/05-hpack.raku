#!/usr/bin/env rakupp
# Encoding::Huffman::PP6 — It is not HPACK-compatible
# https://raku.online/modules/encoding-huffman-pp6/#it-is-not-hpack-compatible
#
# Install what it needs, then run it:
#     rakupp install Encoding::Huffman::PP6
#     rakupp 05-hpack.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Encoding::Huffman::PP6;

say 'despite using the HPACK table, the OUTPUT is not HPACK:';
say '  HPACK pads with the EOS PREFIX to the next byte boundary;';
say '  this module emits the whole 30-bit EOS symbol.';
say '';
say '  huffman-encode("")                 : ', huffman-encode('').bytes, ' bytes (HPACK: 0)';
say '  huffman-encode("www.example.com")  : ',
    huffman-encode('www.example.com').bytes, ' bytes (HPACK: 12)';
say '';
say 'the DECODER is tolerant enough to read HPACK-style input:';
say '  huffman-decode(Buf[uint8].new(0x1f)) = ',
    huffman-decode(Buf[uint8].new(0x1f)).raku;
say '';
say 'so the asymmetry only bites on encode. Do not put this on a wire';
say 'that expects HPACK.';

# Output:
#     despite using the HPACK table, the OUTPUT is not HPACK:
#       HPACK pads with the EOS PREFIX to the next byte boundary;
#       this module emits the whole 30-bit EOS symbol.
#     
#       huffman-encode("")                 : 4 bytes (HPACK: 0)
#       huffman-encode("www.example.com")  : 15 bytes (HPACK: 12)
#     
#     the DECODER is tolerant enough to read HPACK-style input:
#       huffman-decode(Buf[uint8].new(0x1f)) = "a"
#     
#     so the asymmetry only bites on encode. Do not put this on a wire
#     that expects HPACK.
