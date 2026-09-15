#!/usr/bin/env rakupp
# Encoding::Huffman::PP6 — Any byte sequence is "valid input"
# https://raku.online/modules/encoding-huffman-pp6/#any-byte-sequence-is-valid-input
#
# Install what it needs, then run it:
#     rakupp install Encoding::Huffman::PP6
#     rakupp 04-garbage.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Encoding::Huffman::PP6;

for Buf[uint8].new(), Buf[uint8].new(0, 0, 0), Buf[uint8].new(0x12, 0x34, 0x56) -> $b {
    my $r = try huffman-decode($b);
    say sprintf('  %-28s -> %s', $b.list.map({ .fmt('%02x') }).join.raku,
                $! ?? 'threw' !! $r.raku);
}
say '';
say 'never an exception, never an undefined value — always a Str. There';
say 'is no checksum, no trailing-padding validation, and no way to tell a';
say 'corrupt buffer from a good one.';
say '';
say 'and encoding a character ABSENT from the table is silent too:';
my $euro = huffman-encode("\c[EURO SIGN]");
say '  huffman-encode("€") = ', $euro.list.map({ .fmt('%02x') }).join,
    '   <- the EOS alone';

# Output:
#       ""                           -> ""
#       "000000"                     -> "\0\0\0\0"
#       "123456"                     -> "\x[2]sMp"
#     
#     never an exception, never an undefined value — always a Str. There
#     is no checksum, no trailing-padding validation, and no way to tell a
#     corrupt buffer from a good one.
#     
#     and encoding a character ABSENT from the table is silent too:
#       huffman-encode("€") = fffffffc   <- the EOS alone
