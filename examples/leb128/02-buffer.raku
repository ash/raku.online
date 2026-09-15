#!/usr/bin/env rakupp
# LEB128 — Splicing into a buffer
# https://raku.online/modules/leb128/#splicing-into-a-buffer
#
# Install what it needs, then run it:
#     rakupp install LEB128
#     rakupp 02-buffer.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LEB128;

my Buf $buf .= new;
my int $offset = 0;

for 300, 7, 624485 -> $v {
    my $written = encode-leb128-unsigned($v, $buf, $offset);
    say sprintf('encoded %-8s at offset %-2d -> %d byte(s) written, buffer now %s',
        $v.Str, $offset, $written, $buf.list.map({ .fmt('%02X') }).join(' '));
    $offset += $written;
}

# Output:
#     encoded 300      at offset 0  -> 2 byte(s) written, buffer now AC 02
#     encoded 7        at offset 2  -> 1 byte(s) written, buffer now AC 02 07
#     encoded 624485   at offset 3  -> 3 byte(s) written, buffer now AC 02 07 E5 8E 26
