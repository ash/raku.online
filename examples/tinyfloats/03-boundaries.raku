#!/usr/bin/env rakupp
# TinyFloats — Boundaries
# https://raku.online/modules/tinyfloats/#boundaries
#
# Install what it needs, then run it:
#     rakupp install TinyFloats
#     rakupp 03-boundaries.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TinyFloats;

say 'bin16 maximum finite value 65504 : 0x', bin16-from-num(65504e0).base(16);
say 'bin16 of 70000 overflows to Inf  : ', num-from-bin16(bin16-from-num(70000e0)).gist;
say 'bin16 of 1e-8 underflows to zero : ', num-from-bin16(bin16-from-num(1e-8)).gist;
say '';
say 'e5m2 maximum finite value 57344  : ', num-from-e5m2(e5m2-from-num(57344e0)).gist;
say 'e5m2 of 1e6 overflows to Inf     : ', num-from-e5m2(e5m2-from-num(1e6)).gist;
say '';
say 'negative zero keeps its sign bit : 0x', bin16-from-num(-0e0).base(16);

# Output:
#     bin16 maximum finite value 65504 : 0x7BFF
#     bin16 of 70000 overflows to Inf  : Inf
#     bin16 of 1e-8 underflows to zero : 0
#     
#     e5m2 maximum finite value 57344  : 57344
#     e5m2 of 1e6 overflows to Inf     : Inf
#     
#     negative zero keeps its sign bit : 0x8000
