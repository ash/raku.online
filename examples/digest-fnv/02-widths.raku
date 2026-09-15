#!/usr/bin/env rakupp
# Digest::FNV — Widths and variants
# https://raku.online/modules/digest-fnv/#widths-and-variants
#
# Install what it needs, then run it:
#     rakupp install Digest::FNV
#     rakupp 02-widths.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::FNV :DEFAULT, :DEPRECATED;

say 'default width  : ', fnv1a('foobar') == fnv1a('foobar', :bits(64)) ?? '64' !! '?';
say '';
for 32, 64, 128, 256 -> $b {
    say sprintf('  :bits(%-4d) -> %s', $b, fnv1a('foobar', :bits($b)).base(16).lc);
}
say '';
say 'fnv1  vs fnv1a differ by the order of xor and multiply:';
say '  fnv1  : ', fnv1('foobar');
say '  fnv1a : ', fnv1a('foobar');
say '  fnv0  : ', fnv0('foobar');

# Output:
#     default width  : 64
#     
#       :bits(32  ) -> bf9cf968
#       :bits(64  ) -> 85944171f73967e8
#       :bits(128 ) -> 343e1662793c64bf6f0d3597ba446f18
#       :bits(256 ) -> b055ea2f306cadad4f0f81c02d3889dc32453dad5ae35b753ba1a91084af3428
#     
#     fnv1  vs fnv1a differ by the order of xor and multiply:
#       fnv1  : 3750802935296928194
#       fnv1a : 9625390261332436968
#       fnv0  : 833638993740285423
