#!/usr/bin/env rakupp
# LEB128 — Encoding and decoding
# https://raku.online/modules/leb128/#encoding-and-decoding
#
# Install what it needs, then run it:
#     rakupp install LEB128
#     rakupp 01-leb.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LEB128;

sub hex(Buf $b) { $b.list.map({ .fmt('%02X') }).join(' ') }

say 'unsigned:';
for 0, 1, 127, 128, 300, 624485, 2**64 -> $v {
    my Buf $e = encode-leb128-unsigned($v);
    say sprintf('  %-22s %2d bytes  %-30s -> %s',
        $v.Str, $e.elems, hex($e), decode-leb128-unsigned($e).Str);
}
say '';
say 'signed:';
for 0, 63, 64, -1, -64, -65, 624485, -624485 -> $v {
    my Buf $e = encode-leb128-signed($v);
    say sprintf('  %-10s %2d bytes  %-12s -> %s',
        $v.Str, $e.elems, hex($e), decode-leb128-signed($e).Str);
}

# Output:
#     unsigned:
#       0                       1 bytes  00                             -> 0
#       1                       1 bytes  01                             -> 1
#       127                     1 bytes  7F                             -> 127
#       128                     2 bytes  80 01                          -> 128
#       300                     2 bytes  AC 02                          -> 300
#       624485                  3 bytes  E5 8E 26                       -> 624485
#       18446744073709551616   10 bytes  80 80 80 80 80 80 80 80 80 02  -> 18446744073709551616
#     
#     signed:
#       0           1 bytes  00           -> 0
#       63          1 bytes  3F           -> 63
#       64          2 bytes  C0 00        -> 64
#       -1          1 bytes  7F           -> -1
#       -64         1 bytes  40           -> -64
#       -65         2 bytes  BF 7F        -> -65
#       624485      3 bytes  E5 8E 26     -> 624485
#       -624485     3 bytes  9B F1 59     -> -624485
