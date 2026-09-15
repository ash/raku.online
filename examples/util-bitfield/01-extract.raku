#!/usr/bin/env rakupp
# Util::Bitfield — Extracting a field
# https://raku.online/modules/util-bitfield/#extracting-a-field
#
# Install what it needs, then run it:
#     rakupp install Util::Bitfield
#     rakupp 01-extract.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Util::Bitfield;

my $word = 0b1010_1100_0011_0101_1111_0000_1001_0110;
say 'word = ', $word.base(2), ' (0x', $word.base(16), ')';
say '';

for (4, 0), (4, 4), (8, 0), (8, 8), (8, 24), (16, 0), (16, 16) -> ($bits, $start) {
    my $x = extract-bits($word, $bits, $start);
    say sprintf('extract-bits(word, bits=%-2d, start=%-2d) = %-6d 0b%s',
        $bits, $start, $x, $x.base(2));
}

# Output:
#     word = 10101100001101011111000010010110 (0xAC35F096)
#     
#     extract-bits(word, bits=4 , start=0 ) = 10     0b1010
#     extract-bits(word, bits=4 , start=4 ) = 12     0b1100
#     extract-bits(word, bits=8 , start=0 ) = 172    0b10101100
#     extract-bits(word, bits=8 , start=8 ) = 53     0b110101
#     extract-bits(word, bits=8 , start=24) = 150    0b10010110
#     extract-bits(word, bits=16, start=0 ) = 44085  0b1010110000110101
#     extract-bits(word, bits=16, start=16) = 61590  0b1111000010010110
