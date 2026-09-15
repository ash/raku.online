#!/usr/bin/env rakupp
# LEB128 — Where the two engines differ
# https://raku.online/modules/leb128/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install LEB128
#     rakupp 04-native-int.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LEB128;

my Buf $buf .= new;
my int $native = 0;
say 'a native int offset works on both engines : ',
    encode-leb128-unsigned(300, $buf, $native), ' byte(s)';
say 'and the buffer holds : ', $buf.list.map({ .fmt('%02X') }).join(' ');

# Output:
#     a native int offset works on both engines : 2 byte(s)
#     and the buffer holds : AC 02
