#!/usr/bin/env rakupp
# Image::PNG::Inflated — The one thing to know
# https://raku.online/modules/image-png-inflated/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Image::PNG::Inflated
#     rakupp 03-lying-header.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     the same 16-byte buffer, declared three ways:
#       2x2 -> built a well-formed PNG;  IHDR needs 18 filtered bytes, the buffer has 16
#       4x4 -> built a well-formed PNG;  IHDR needs 68 filtered bytes, the buffer has 16
#       1x4 -> built a well-formed PNG;  IHDR needs 20 filtered bytes, the buffer has 16
#     
#     nothing raises. Every cheap sanity check passes and real decoders
#     reject the file.
#     
#     the same silence covers the far more likely mistake — handing it an
#     RGB buffer. 3 bytes per pixel is accepted without a word, and the
#     filter-insertion loop then slices scanlines at the wrong stride, so
#     the image comes out sheared:
#       to-png(12 bytes, 2, 2) -> built a PNG, no error
#     
#     check it yourself:
#       guarded : buffer is 12 bytes; 2x2 RGBA needs 16
