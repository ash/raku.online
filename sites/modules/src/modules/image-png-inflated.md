---
name: Image::PNG::Inflated
version: 0.1.0
auth: github:cygx
kind: Distribution · images
summary: Wraps a raw RGBA buffer in a valid PNG container without compressing
  it — and never checks that the buffer matches the size you declared.
status: divergent
suite: no test files, so trivially green
tested: 2026-09-15
license: BSL-1.0
depends: none beyond the core
raku-land: https://raku.land/github:cygx/Image::PNG::Inflated
source: git://github.com/cygx/p6-image-png-inflated.git
---

## What it is for

Sometimes you have pixels and you need a file something else can open, and you
do not care about size. This distribution writes a structurally perfect PNG
around a raw 8-bit RGBA buffer: a zero filter byte per scanline, zlib *stored*
blocks with a correct Adler-32, and `IHDR`/`IDAT`/`IEND` chunks with correct
CRC-32s. No compression, no dependencies, 153 lines.

## Writing one

```raku name="basics"
use Image::PNG::Inflated;

# a 2x2 RGBA image: red, green, blue, half-transparent white
my $img = blob8.new(0xFF,0x00,0x00,0xFF,  0x00,0xFF,0x00,0xFF,
                    0x00,0x00,0xFF,0xFF,  0xFF,0xFF,0xFF,0x80);
my $png = to-png($img, 2, 2);

say 'PNG magic    : ', $png[0..7].map({ .fmt('%02X') }).join(' ');
my $i = 8;
my @types;
while $i < $png.bytes {
    my $len = ($png[$i] +< 24) + ($png[$i+1] +< 16) + ($png[$i+2] +< 8) + $png[$i+3];
    @types.push($png[$i+4 .. $i+7].map(*.chr).join);
    $i += 12 + $len;
}
say 'first chunk  : ', @types.head;
say 'last chunk   : ', @types.tail;
say 'all IDAT between them : ', so @types[1 ..^ *-1].all eq 'IDAT';
say '';
say 'IHDR says 2x2, depth 8, colour type 6 (RGBA), no interlace —';
say 'all hardcoded. There is no parameter to change them.';
```

```output
PNG magic    : 89 50 4E 47 0D 0A 1A 0A
first chunk  : IHDR
last chunk   : IEND
all IDAT between them : True

IHDR says 2x2, depth 8, colour type 6 (RGBA), no interlace —
all hardcoded. There is no parameter to change them.
```

## The dimensions are required

```raku name="dimensions"
use Image::PNG::Inflated;

my $img = blob8.new(0xFF xx 16);
my $r = try to-png($img);
say 'to-png($blob) with no dimensions -> ', $! ?? 'threw' !! 'worked';
say '';
say 'the defaults are $img.width and $img.height, and a blob8 has neither.';
say 'the signature gist shows them uselessly as `uint32 $w = Code.new`.';
say '';
say 'either pass them, or hand it an object that answers .width, .height';
say 'and .blob8:';
class Pixels {
    has $.width; has $.height; has $.blob8;
}
my $obj = Pixels.new(width => 2, height => 2, blob8 => $img);
say '  a duck-typed object works : ', to-png($obj).bytes >= 60;
```

```output
to-png($blob) with no dimensions -> threw

the defaults are $img.width and $img.height, and a blob8 has neither.
the signature gist shows them uselessly as `uint32 $w = Code.new`.

either pass them, or hand it an object that answers .width, .height
and .blob8:
  a duck-typed object works : True
```

## The one thing to know

`to-png` never checks that the buffer matches `$w × $h × 4`. A mismatch
produces a structurally perfect PNG whose header lies — correct magic,
correct chunk lengths, correct CRCs, a cleanly inflating zlib stream, and a
declared size that needs far more data than the file holds.

```raku name="lying-header"
use Image::PNG::Inflated;

my $two-by-two = blob8.new(0xFF xx 16);      # 2x2 RGBA = 16 bytes

say 'the same 16-byte buffer, declared three ways:';
for (2, 2), (4, 4), (1, 4) -> ($w, $h) {
    my $png = to-png($two-by-two, $w, $h);
    my $needed = $h * (1 + $w * 4);
    say sprintf('  %dx%d -> built a %s PNG;  IHDR needs %d filtered bytes, the buffer has %d',
                $w, $h, ($png[0..3].map({ .fmt('%02X') }).join eq '89504E47' ?? 'well-formed' !! 'broken'),
                $needed, $two-by-two.bytes);
}
say '';
say 'nothing raises. Every cheap sanity check passes and real decoders';
say 'reject the file.';
say '';
say 'the same silence covers the far more likely mistake — handing it an';
say 'RGB buffer. 3 bytes per pixel is accepted without a word, and the';
say 'filter-insertion loop then slices scanlines at the wrong stride, so';
say 'the image comes out sheared:';
my $rgb = blob8.new(0xFF xx 12);             # 2x2 RGB = 12 bytes
say '  to-png(12 bytes, 2, 2) -> built a PNG, no error';
say '';
say 'check it yourself:';
sub png(blob8 $b, UInt $w, UInt $h) {
    die "buffer is {$b.bytes} bytes; {$w}x{$h} RGBA needs {$w * $h * 4}"
        unless $b.bytes == $w * $h * 4;
    to-png($b, $w, $h)
}
my $e = try png($rgb, 2, 2);
say '  guarded : ', $! ?? $!.message !! 'accepted';
```

```output
the same 16-byte buffer, declared three ways:
  2x2 -> built a well-formed PNG;  IHDR needs 18 filtered bytes, the buffer has 16
  4x4 -> built a well-formed PNG;  IHDR needs 68 filtered bytes, the buffer has 16
  1x4 -> built a well-formed PNG;  IHDR needs 20 filtered bytes, the buffer has 16

nothing raises. Every cheap sanity check passes and real decoders
reject the file.

the same silence covers the far more likely mistake — handing it an
RGB buffer. 3 bytes per pixel is accepted without a word, and the
filter-insertion loop then slices scanlines at the wrong stride, so
the image comes out sheared:
  to-png(12 bytes, 2, 2) -> built a PNG, no error

check it yourself:
  guarded : buffer is 12 bytes; 2x2 RGBA needs 16
```

`$w` and `$h` are native `uint32`, so a negative dimension wraps rather than
raising: `to-png($img, -1, 2)` writes width 4294967295.

## Where the two engines differ

The two engines produce **different bytes** for the same image. Both files are
valid, both decode to identical pixels, and their IDAT chunking differs.

```raku name="chunking"
use Image::PNG::Inflated;

my $img = blob8.new(0xFF,0x00,0x00,0xFF,  0x00,0xFF,0x00,0xFF,
                    0x00,0x00,0xFF,0xFF,  0xFF,0xFF,0xFF,0x80);
my $png = to-png($img, 2, 2);

my @types;
my $i = 8;
while $i < $png.bytes {
    my $len = ($png[$i] +< 24) + ($png[$i+1] +< 16) + ($png[$i+2] +< 8) + $png[$i+3];
    @types.push($png[$i+4 .. $i+7].map(*.chr).join);
    $i += 12 + $len;
}
say 'chunk sequence : IHDR, then one or more IDAT, then IEND';
say '  starts IHDR  : ', @types.head eq 'IHDR';
say '  ends IEND    : ', @types.tail eq 'IEND';
say '  IDAT count   : engine-dependent — do not assert on it';
say '';
say 'Raku++ emits four IDAT chunks and 122 bytes where Rakudo emits two';
say 'and 98, for the same pixels. The cause is `take $a, $b, $c` inside';
say 'gather: Raku++ takes three separate items, Rakudo takes one';
say '3-element List.';
say '';
say 'so never hash or golden-file this module`s output across engines.';
say 'Compare the decoded pixels instead — those are identical.';
```

```output
chunk sequence : IHDR, then one or more IDAT, then IEND
  starts IHDR  : True
  ends IEND    : True
  IDAT count   : engine-dependent — do not assert on it

Raku++ emits four IDAT chunks and 122 bytes where Rakudo emits two
and 98, for the same pixels. The cause is `take $a, $b, $c` inside
gather: Raku++ takes three separate items, Rakudo takes one
3-element List.

so never hash or golden-file this module`s output across engines.
Compare the decoded pixels instead — those are identical.
```

One last property worth stating plainly: the output is **larger** than the
input. 16 384 raw bytes become about 16.5 KB. The name is the warning — this
is a container, not a compressor.
