#!/usr/bin/env rakupp
# Image::PNG::Inflated — Writing one
# https://raku.online/modules/image-png-inflated/#writing-one
#
# Install what it needs, then run it:
#     rakupp install Image::PNG::Inflated
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     PNG magic    : 89 50 4E 47 0D 0A 1A 0A
#     first chunk  : IHDR
#     last chunk   : IEND
#     all IDAT between them : True
#     
#     IHDR says 2x2, depth 8, colour type 6 (RGBA), no interlace —
#     all hardcoded. There is no parameter to change them.
