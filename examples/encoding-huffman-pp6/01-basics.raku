#!/usr/bin/env rakupp
# Encoding::Huffman::PP6 — Encoding
# https://raku.online/modules/encoding-huffman-pp6/#encoding
#
# Install what it needs, then run it:
#     rakupp install Encoding::Huffman::PP6
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Encoding::Huffman::PP6;

for 'www.example.com', 'a', '', 'no-cache' -> $s {
    my $b = huffman-encode($s);
    say sprintf('  %-18s %2d bytes  %s', $s.raku, $b.bytes,
                $b.list.map({ .fmt('%02x') }).join);
}
say '';
say 'the encoder always terminates with the table`s 30-bit EOS symbol and';
say 'zero-pads to a byte boundary, so even the empty string is 4 bytes.';

# Output:
#       "www.example.com"  15 bytes  f1e3c2e5f23a6ba0ab90f4fffffffe
#       "a"                 5 bytes  1fffffffe0
#       ""                  4 bytes  fffffffc
#       "no-cache"         10 bytes  a8eb10649cbfffffff80
#     
#     the encoder always terminates with the table`s 30-bit EOS symbol and
#     zero-pads to a byte boundary, so even the empty string is 4 bytes.
