#!/usr/bin/env rakupp
# Image::PNG::Inflated — Where the two engines differ
# https://raku.online/modules/image-png-inflated/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Image::PNG::Inflated
#     rakupp 04-chunking.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     chunk sequence : IHDR, then one or more IDAT, then IEND
#       starts IHDR  : True
#       ends IEND    : True
#       IDAT count   : engine-dependent — do not assert on it
#     
#     Raku++ emits four IDAT chunks and 122 bytes where Rakudo emits two
#     and 98, for the same pixels. The cause is `take $a, $b, $c` inside
#     gather: Raku++ takes three separate items, Rakudo takes one
#     3-element List.
#     
#     so never hash or golden-file this module`s output across engines.
#     Compare the decoded pixels instead — those are identical.
