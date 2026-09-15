#!/usr/bin/env rakupp
# Netstring — Bytes out
# https://raku.online/modules/netstring/#bytes-out
#
# Install what it needs, then run it:
#     rakupp install Netstring
#     rakupp 02-buf.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Netstring;

sub hex($b) { $b.list.map({ .fmt('%02X') }).join(' ') }

my $u = 'caf' ~ "\c[LATIN SMALL LETTER E WITH ACUTE]";
say 'to-netstring-buf : ', hex(to-netstring-buf($u));
say '';
my $binary = Blob.new(0x00, 0x01, 0xFF, 0xFE, 0x80);
say 'a blob that is not valid UTF-8:';
say '  bytes            : ', hex($binary);
say '  to-netstring-buf : ', hex(to-netstring-buf($binary));

# Output:
#     to-netstring-buf : 35 3A 63 61 66 C3 A9 2C
#     
#     a blob that is not valid UTF-8:
#       bytes            : 00 01 FF FE 80
#       to-netstring-buf : 35 3A 00 01 FF FE 80 2C
