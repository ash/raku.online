#!/usr/bin/env rakupp
# TinyFloats — Where the two engines differ
# https://raku.online/modules/tinyfloats/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install TinyFloats
#     rakupp 04-range.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TinyFloats;

say 'num-from-bin16(-1)      : ', num-from-bin16(-1).gist;
say 'num-from-bin16(0x1FFFF) : ', num-from-bin16(0x1FFFF).gist, '   (17 bits wide)';
say 'a genuine NaN pattern   : ', num-from-bin16(0x7E00).gist;
say '';
say 'all three are indistinguishable by their result';

# Output:
#     num-from-bin16(-1)      : NaN
#     num-from-bin16(0x1FFFF) : NaN   (17 bits wide)
#     a genuine NaN pattern   : NaN
#     
#     all three are indistinguishable by their result
