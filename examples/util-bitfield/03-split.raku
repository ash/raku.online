#!/usr/bin/env rakupp
# Util::Bitfield — Splitting a value into bits
# https://raku.online/modules/util-bitfield/#splitting-a-value-into-bits
#
# Install what it needs, then run it:
#     rakupp install Util::Bitfield
#     rakupp 03-split.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Util::Bitfield;

say 'split-bits(8, 255)    : ', split-bits(8, 255).List.raku;
say 'split-bits(8, 0b1010) : ', split-bits(8, 0b1010).List.raku;
say 'split-bits(16, 0xAC35): ', split-bits(16, 0xAC35).List.raku;
say '';
say 'the value must fit in the width:';
say '  split-bits(8, 256) -> ', (try split-bits(8, 256)).defined ?? 'accepted' !! 'refused';

# Output:
#     split-bits(8, 255)    : (1, 1, 1, 1, 1, 1, 1, 1)
#     split-bits(8, 0b1010) : (0, 0, 0, 0, 1, 0, 1, 0)
#     split-bits(16, 0xAC35): (1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1)
#     
#     the value must fit in the width:
#       split-bits(8, 256) -> refused
