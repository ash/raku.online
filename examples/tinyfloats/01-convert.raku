#!/usr/bin/env rakupp
# TinyFloats — Converting
# https://raku.online/modules/tinyfloats/#converting
#
# Install what it needs, then run it:
#     rakupp install TinyFloats
#     rakupp 01-convert.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TinyFloats;

for 0e0, 1e0, -1e0, 0.5e0, 3.14e0, 65504e0, Inf, -Inf -> $n {
    my $bits = bin16-from-num($n);
    say sprintf('%-10s bits=0x%04X  back=%s', $n.gist, $bits, num-from-bin16($bits).gist);
}
say '';
my $nan = bin16-from-num(NaN);
say sprintf('NaN        bits=0x%04X  back=%s (isNaN=%s)',
    $nan, num-from-bin16($nan).gist, num-from-bin16($nan).isNaN);

# Output:
#     0          bits=0x0000  back=0
#     1          bits=0x3C00  back=1
#     -1         bits=0xBC00  back=-1
#     0.5        bits=0x3800  back=0.5
#     3.14       bits=0x4247  back=3.138671875
#     65504      bits=0x7BFF  back=65504
#     Inf        bits=0x7C00  back=Inf
#     -Inf       bits=0xFC00  back=-Inf
#     
#     NaN        bits=0x7E00  back=NaN (isNaN=True)
