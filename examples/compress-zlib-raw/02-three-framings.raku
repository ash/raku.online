#!/usr/bin/env rakupp
# Compress::Zlib::Raw — The one thing to know
# https://raku.online/modules/compress-zlib-raw/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Compress::Zlib::Raw
#     rakupp 02-three-framings.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Compress::Zlib::Raw;
use NativeCall;

constant Z_DEFLATED = 8;
constant Z_FINISH   = 4;

sub deflate-with(Int $windowbits, Blob $src) {
    my $z = Compress::Zlib::Raw::z_stream.new;
    deflateInit2($z, 6, Z_DEFLATED, $windowbits, 8, 0);
    my $out = Buf[uint8].allocate(512);
    $z.set-input($src);
    $z.set-output($out);
    deflate($z, Z_FINISH);
    my $n = $z.total-out;
    deflateEnd($z);
    Buf[uint8].new($out[^$n])
}

my $src = 'hello hello hello hello hello'.encode('ascii');
for 15, -15, 31 -> $wb {
    my $b = deflate-with($wb, $src);
    say sprintf('windowbits %3d : %2d bytes, starts %s',
                $wb, $b.elems, $b.list.head(2).map({ .fmt('%02x') }).join(' '));
}

my $raw = deflate-with(-15, $src);
my $out = Buf[uint8].allocate(128);
my $len = CArray[long].new; $len[0] = 128;
say 'uncompress on a raw deflate stream: ', uncompress($out, $len, $raw, $raw.elems);

# Output:
#     windowbits  15 : 17 bytes, starts 78 9c
#     windowbits -15 : 11 bytes, starts cb 48
#     windowbits  31 : 29 bytes, starts 1f 8b
#     uncompress on a raw deflate stream: -3
