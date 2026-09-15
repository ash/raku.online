#!/usr/bin/env rakupp
# TinyFloats — The four formats side by side
# https://raku.online/modules/tinyfloats/#the-four-formats-side-by-side
#
# Install what it needs, then run it:
#     rakupp install TinyFloats
#     rakupp 02-formats.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TinyFloats;

for 1e0, 0.1e0 -> $n {
    say sprintf('%-6s bin16=0x%04X  bf16=0x%04X  e5m2=0x%02X  tf32=0x%08X',
        $n.gist, bin16-from-num($n), bf16-from-num($n), e5m2-from-num($n), tf32-from-num($n));
    say sprintf('       back: bin16=%-22s bf16=%-16s e5m2=%-10s tf32=%s',
        num-from-bin16(bin16-from-num($n)).gist,
        num-from-bf16(bf16-from-num($n)).gist,
        num-from-e5m2(e5m2-from-num($n)).gist,
        num-from-tf32(tf32-from-num($n)).gist);
}

# Output:
#     1      bin16=0x3C00  bf16=0x3F80  e5m2=0x3C  tf32=0x0001FC00
#            back: bin16=1                      bf16=1                e5m2=1          tf32=1
#     0.1    bin16=0x2E66  bf16=0x3DCC  e5m2=0x2E  tf32=0x0001EE66
#            back: bin16=0.0999755859375        bf16=0.099609375      e5m2=0.09375    tf32=0.0999755859375
