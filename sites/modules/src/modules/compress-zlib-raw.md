---
name: Compress::Zlib::Raw
version: 1.0.1
kind: Distribution · encoding
summary: The zlib C library bound function for function — the one-shot
  helpers, the streaming deflate and inflate state machine, and the
  checksums — with no Raku wrapper over any of it.
status: full
suite: 1 file, green
tested: 2026-09-15
raku-land: https://raku.land/github:retupmoca/Compress::Zlib::Raw
source: https://github.com/retupmoca/P6-Compress-Zlib-Raw
---

## What it is for

Everything that compresses is zlib: the `.gz` files on disk, the
`Content-Encoding: gzip` on the wire, the compressed chunk inside a PNG,
the objects in a git repository. A Raku program that has to read or write
any of those formats byte-for-byte needs the library itself rather than a
convenience layer, because the details it would hide — which of the three
framings, which window size, which compression level — are exactly the
details the format specifies.

This distribution is sixty-three functions bound straight through, plus the
three C structures they pass around. Nothing is wrapped and nothing is made
convenient; you allocate the destination buffer, pass the length in and out
through a one-element array, and read the integer return codes yourself.

## A round trip, and the checksums

```raku name="roundtrip"
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
```

```output
1.2.12
24
0
29 bytes in, 17 out
78 9c cb 48
0
hello hello hello hello hello
```

Zero is `Z_OK`; every other return code is a problem, and there are no
exceptions anywhere in the binding. `compressBound` tells you how large the
output buffer must be for the worst case, which is the only safe size to
allocate.

## The one thing to know

"Raw" in the name means raw *bindings*, not zlib's raw-deflate mode. What
`compress` produces is the zlib framing — a two-byte header and a checksum
trailer — which is neither a bare deflate stream nor a gzip file:

```raku name="three-framings"
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
```

```output
windowbits  15 : 17 bytes, starts 78 9c
windowbits -15 : 11 bytes, starts cb 48
windowbits  31 : 29 bytes, starts 1f 8b
uncompress on a raw deflate stream: -3
```

The three window-size settings select the three framings: 15 is zlib, −15
is raw deflate with no header at all, and 31 is gzip — which is why the
gzip form starts with the familiar `1f 8b` magic. `uncompress` handles only
the first, and answers `-3`, `Z_DATA_ERROR`, for the other two. If you want
to write a `.gz` file, you drive `deflateInit2` yourself with 31.

One trap worth naming because it is silent: on a `Z_BUF_ERROR` the
destination buffer still contains the partial result, so a caller that
ignores the return code gets truncated data that looks like data. Check
every return code, always.

The checksum functions take a `CArray[int8]`, not a `Blob`. Raku++ accepts
a `Blob` there and Rakudo refuses it, so convert explicitly if the code has
to run on both — and remember `int8` is signed, so bytes above 127 need
wrapping.
