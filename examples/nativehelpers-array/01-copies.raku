#!/usr/bin/env rakupp
# NativeHelpers::Array — The four copies
# https://raku.online/modules/nativehelpers-array/#the-four-copies
#
# Install what it needs, then run it:
#     rakupp install NativeHelpers::Array
#     rakupp 01-copies.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use NativeCall;
use NativeHelpers::Array;

my $c = copy-to-carray([3, 1, 4, 1, 5], int32);
say $c.elems, ' ', $c[2], ' ', $c.of;
say copy-to-array($c, 5);
say copy-to-array($c, 3);

my $bytes = copy-buf-to-carray(Buf.new(72, 105, 33));
say $bytes.of, ' ', $bytes.elems;
say copy-carray-to-buf($bytes, 3).decode;
say copy-carray-to-buf($bytes, 2).decode;

# Output:
#     5 4 (int32)
#     [3 1 4 1 5]
#     [3 1 4]
#     (uint8) 3
#     Hi!
#     Hi
