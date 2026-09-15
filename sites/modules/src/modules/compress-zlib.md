---
name: Compress::Zlib
version: 1.1.0
auth: github:retupmoca
kind: Distribution · encoding
summary: compress and uncompress over libz, plus the three framings — raw
  deflate, a zlib header, a gzip header — and a filehandle wrapper that reads or
  writes a gzip file as if it were text.
status: full
suite: 3 files, green
tested: 2026-09-16
license: (none stated)
depends: Compress::Zlib::Raw
raku-land: https://raku.land/github:retupmoca/Compress::Zlib
source: https://github.com/retupmoca/P6-Compress-Zlib.git
---

## What it is for

Three things share the name "zlib" and they are not interchangeable. There is
the DEFLATE algorithm; there is the two-byte zlib framing around it that RFC
1950 describes; and there is the gzip framing of RFC 1952, with its magic
number, timestamp and CRC. A library that gives you only one of the three
cannot read a `.gz` file, or cannot write the payload of a PNG chunk.

This distribution gives you all three, over the real libz through
`Compress::Zlib::Raw`, and it is the reason the eight distributions that depend
on it do not each bind their own FFI.

## Round trips and levels

```raku name="zlib"
use Compress::Zlib;

my $text = ('The quick brown fox jumps over the lazy dog. ' x 20).encode;
say 'original      : ', $text.bytes, ' bytes';

for 1, 6, 9 -> $level {
    my $z = compress($text, $level);
    say sprintf('level %d       : %4d bytes   round-trips: %s',
                $level, $z.bytes, uncompress($z).decode eq $text.decode);
}

say '';
say 'header of compress() : ', compress($text)[0..1]».fmt('%02x').join(' '), '   (zlib)';

my $gz = $*TMPDIR.add('zlib-demo-' ~ $*PID ~ '.gz');
gzspurt($gz.Str, $text.decode);
say 'header of a gzspurt  : ', $gz.slurp(:bin)[0..2]».fmt('%02x').join(' '), '   (gzip)';
say 'gzslurp round-trips  : ', gzslurp($gz.Str) eq $text.decode;
$gz.unlink;
```

```output
original      : 900 bytes
level 1       :   63 bytes   round-trips: True
level 6       :   61 bytes   round-trips: True
level 9       :   61 bytes   round-trips: True

header of compress() : 78 9c   (zlib)
header of a gzspurt  : 1f 8b 08   (gzip)
gzslurp round-trips  : True
```

The level is the usual 1–9 and the usual disappointment: on text this
repetitive, level 1 is within two bytes of level 9, and the gap that matters in
practice is between compressing and not. `compress` takes a `Blob` and returns
a `Buf`, so encoding is your business — the `.encode` and `.decode` above are
not decoration.

The headers are the point of the last three lines. `compress` writes `78 9c`,
the zlib framing. `gzspurt` writes `1f 8b 08`, the gzip magic and the deflate
method byte, which is what `gunzip` and every browser expect.

## The three framings

`zwrap` is the switch between them, and it is the part of the API most likely
to surprise: it does **not** return a `Buf`. It returns a
`Compress::Zlib::Wrap` — a filehandle-like object with `.get`, `.lines`,
`.slurp`, `.print` and `.close` — because its job is to wrap a *stream*, not to
transform a buffer.

```raku fragment
my $wrapped = zwrap($fh, :gzip);   # a Wrap around a handle, not bytes
$wrapped.print("...");             # goes through the compressor
$wrapped.close;

zwrap($blob, :gzip).bytes          # No such method 'bytes' — this is the trap
```

So there are two levels to the API. `compress`/`uncompress` are buffer-to-buffer
and take the zlib framing. `zwrap` plus `gzslurp`/`gzspurt` are the stream
level, and `:zlib`, `:deflate` and `:gzip` choose the framing there.

## Where the two engines differ

Nowhere. Every level, both round trips, both headers and the `gzslurp` read
produced identical output on Raku++ and Rakudo, and the distribution's three
test files pass whole on both.

Two things to know that are not engine-related. The distribution states no
license, which matters if you are vendoring it. And `uncompress` on data that is
not valid zlib does not throw a typed exception — it comes back from libz as an
error the wrapper turns into a generic failure, so a program reading untrusted
bytes should check the result rather than rely on catching something specific.
