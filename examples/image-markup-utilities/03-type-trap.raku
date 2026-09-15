#!/usr/bin/env rakupp
# Image::Markup::Utilities — The one thing to know
# https://raku.online/modules/image-markup-utilities/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Image::Markup::Utilities
#     rakupp 03-type-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Image::Markup::Utilities;

my $dir = $*TMPDIR.add("img3-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }
my $png = $dir.add('dot.png');
$png.spurt: Buf.new(
    0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,
    0x49,0x48,0x44,0x52,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,
    0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,0x89,0x00,0x00,0x00,
    0x0A,0x49,0x44,0x41,0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,
    0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,
    0x45,0x4E,0x44,0xAE,0x42,0x60,0x82);

say 'the file is an unambiguous PNG — magic bytes 89 50 4E 47:';
say '  first four bytes : ', $png.slurp(:bin).subbuf(0, 4).list.map({ .fmt('%02X') }).join(' ');
say '';
for '(no :type)', '', ':type<png>', 'png', ':type<gif>', 'gif', ':type<banana>', 'banana' -> $label, $t {
    my $e = $t ?? image-encode($png.absolute, :type($t)) !! image-encode($png.absolute);
    say sprintf('  %-14s -> %s', $label, $e.substr(0, 27));
}
say '';
say 'and image-import has no :type parameter at all,';
say 'so every image it embeds is announced as JPEG.';

# Output:
#     the file is an unambiguous PNG — magic bytes 89 50 4E 47:
#       first four bytes : 89 50 4E 47
#     
#       (no :type)     -> data:image/jpeg;base64,iVBO
#       :type<png>     -> data:image/png;base64,iVBOR
#       :type<gif>     -> data:image/gif;base64,iVBOR
#       :type<banana>  -> data:image/banana;base64,iV
#     
#     and image-import has no :type parameter at all,
#     so every image it embeds is announced as JPEG.
