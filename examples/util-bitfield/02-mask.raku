#!/usr/bin/env rakupp
# Util::Bitfield — Masks and insertion
# https://raku.online/modules/util-bitfield/#masks-and-insertion
#
# Install what it needs, then run it:
#     rakupp install Util::Bitfield
#     rakupp 02-mask.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Util::Bitfield;

sub b($v, $w = 32) { sprintf('%0*b', $w, $v) }

for (4, 0), (4, 4), (8, 8), (1, 31) -> ($bits, $start) {
    say sprintf('make-mask(bits=%-2d start=%-2d) = %s  (0x%08X)',
        $bits, $start, b(make-mask($bits, $start)), make-mask($bits, $start));
}
say 'make-mask(4, 0, :invert)     = ', b(make-mask(4, 0, :invert));
say 'make-mask(8, 0, 16)          = ', b(make-mask(8, 0, 16), 16), '  (word-size 16)';
say '';
my $word = 0b1010_1100_0011_0101_1111_0000_1001_0110;
my $new = insert-bits(0b101, $word, 3, 8);
say 'insert 0b101 at start=8 width=3:';
say '  before : ', b($word);
say '  after  : ', b($new);
say '  reads back as : ', extract-bits($new, 3, 8).base(2);

# Output:
#     make-mask(bits=4  start=0 ) = 11110000000000000000000000000000  (0xF0000000)
#     make-mask(bits=4  start=4 ) = 00001111000000000000000000000000  (0x0F000000)
#     make-mask(bits=8  start=8 ) = 00000000111111110000000000000000  (0x00FF0000)
#     make-mask(bits=1  start=31) = 00000000000000000000000000000001  (0x00000001)
#     make-mask(4, 0, :invert)     = 00001111111111111111111111111111
#     make-mask(8, 0, 16)          = 1111111100000000  (word-size 16)
#     
#     insert 0b101 at start=8 width=3:
#       before : 10101100001101011111000010010110
#       after  : 10101100101101011111000010010110
#       reads back as : 101
