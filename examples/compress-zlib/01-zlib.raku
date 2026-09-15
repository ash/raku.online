#!/usr/bin/env rakupp
# Compress::Zlib — Round trips and levels
# https://raku.online/modules/compress-zlib/#round-trips-and-levels
#
# Install what it needs, then run it:
#     rakupp install Compress::Zlib
#     rakupp 01-zlib.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     original      : 900 bytes
#     level 1       :   63 bytes   round-trips: True
#     level 6       :   61 bytes   round-trips: True
#     level 9       :   61 bytes   round-trips: True
#     
#     header of compress() : 78 9c   (zlib)
#     header of a gzspurt  : 1f 8b 08   (gzip)
#     gzslurp round-trips  : True
