#!/usr/bin/env rakupp
# Compress::Zlib::Raw — A round trip, and the checksums
# https://raku.online/modules/compress-zlib-raw/#a-round-trip-and-the-checksums
#
# Install what it needs, then run it:
#     rakupp install Compress::Zlib::Raw
#     rakupp 01-roundtrip.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Compress::Zlib::Raw;
use NativeCall;

say zlibVersion();
say compressBound(11);

my $source = 'hello hello hello hello hello'.encode('ascii');
my $cap    = compressBound($source.elems);
my $dest   = Buf[uint8].allocate($cap);
my $len    = CArray[long].new; $len[0] = $cap;

say compress($dest, $len, $source, $source.elems);
say $source.elems, ' bytes in, ', $len[0], ' out';
my $packed = Buf[uint8].new($dest[^$len[0]]);
say $packed.list.head(4).map({ .fmt('%02x') }).join(' ');

my $back = Buf[uint8].allocate($source.elems + 16);
my $blen = CArray[long].new; $blen[0] = $back.elems;
say uncompress($back, $blen, $packed, $packed.elems);
say Buf[uint8].new($back[^$blen[0]]).decode('ascii');

# Output:
#     1.2.12
#     24
#     0
#     29 bytes in, 17 out
#     78 9c cb 48
#     0
#     hello hello hello hello hello
