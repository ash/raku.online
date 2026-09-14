#!/usr/bin/env rakupp
# Digest — One sub per algorithm
# https://raku.online/modules/digest/#one-sub-per-algorithm
#
# Install what it needs, then run it:
#     rakupp install Digest
#     rakupp 02-shake.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::SHA3;

sub hex(Blob $b) { $b.list.fmt('%02x', '') }

say hex([~] shake128('abc', 16));
say hex([~] shake128('abc', 40));
my @blocks = shake256('abc', *).head(2);
say @blocks.elems, ' blocks of ', @blocks[0].elems, ' bytes';

# Output:
#     5881092dd818bf5cf8a3ddb793fbcba7
#     5881092dd818bf5cf8a3ddb793fbcba74097d5c526a6d35f97b83351940f2cc844c50af32acd3f2c
#     2 blocks of 136 bytes
