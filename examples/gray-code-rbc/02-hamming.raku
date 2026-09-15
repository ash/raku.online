#!/usr/bin/env rakupp
# Gray::Code::RBC — Encoding and decoding
# https://raku.online/modules/gray-code-rbc/#encoding-and-decoding
#
# Install what it needs, then run it:
#     rakupp install Gray::Code::RBC
#     rakupp 02-hamming.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Gray::Code::RBC;

my @codes = (^16).map({ gray-encode($_) });
my @distances = (^15).map({
    (@codes[$_] +^ @codes[$_ + 1]).base(2).comb.grep('1').elems
});
say 'hamming distances between consecutive codes : ', @distances.join(',');
say 'every one of them is 1                      : ', ?all(@distances.map(* == 1));
say 'round trip over 0..999                      : ',
    ?all((^1000).map({ gray-decode(gray-encode($_)) == $_ }));

# Output:
#     hamming distances between consecutive codes : 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
#     every one of them is 1                      : True
#     round trip over 0..999                      : True
