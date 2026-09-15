#!/usr/bin/env rakupp
# MIME::QuotedPrint — Bytes
# https://raku.online/modules/mime-quotedprint/#bytes
#
# Install what it needs, then run it:
#     rakupp install MIME::QuotedPrint
#     rakupp 02-bytes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MIME::QuotedPrint;

constant QP = MIME::QuotedPrint;

my $blob = Blob.new(0x00, 0x1F, 0x3D, 0x41, 0x7F, 0x80, 0xFF);
my $enc  = QP.encode($blob);
my $dec  = QP.decode($enc);

say 'input bytes  : ', $blob.list.map({ .fmt('%02X') }).join(' ');
say 'encoded      : ', $enc.raku;
say 'decoded bytes: ', $dec.list.map({ .fmt('%02X') }).join(' ');
say 'byte-exact   : ', $dec.list eqv $blob.list;

# Output:
#     input bytes  : 00 1F 3D 41 7F 80 FF
#     encoded      : "=00=1F=3DA=7F=80=FF"
#     decoded bytes: 00 1F 3D 41 7F 80 FF
#     byte-exact   : True
