#!/usr/bin/env rakupp
# Image::PNG::Inflated — The dimensions are required
# https://raku.online/modules/image-png-inflated/#the-dimensions-are-required
#
# Install what it needs, then run it:
#     rakupp install Image::PNG::Inflated
#     rakupp 02-dimensions.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     to-png($blob) with no dimensions -> threw
#     
#     the defaults are $img.width and $img.height, and a blob8 has neither.
#     the signature gist shows them uselessly as `uint32 $w = Code.new`.
#     
#     either pass them, or hand it an object that answers .width, .height
#     and .blob8:
#       a duck-typed object works : True
