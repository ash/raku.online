#!/usr/bin/env rakupp
# Gray::Code::RBC — Arbitrary precision
# https://raku.online/modules/gray-code-rbc/#arbitrary-precision
#
# Install what it needs, then run it:
#     rakupp install Gray::Code::RBC
#     rakupp 03-big.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Gray::Code::RBC;

my $big = 2**100 + 12345;
say 'input      : ', $big;
say 'encoded    : ', gray-encode($big);
say 'round trip : ', gray-decode(gray-encode($big)) == $big;
say 'bit width  : ', gray-encode($big).base(2).chars;

# Output:
#     input      : 1267650600228229401496703217721
#     encoded    : 1901475900342344102245054818341
#     round trip : True
#     bit width  : 101
