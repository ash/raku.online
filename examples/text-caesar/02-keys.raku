#!/usr/bin/env rakupp
# Text::Caesar — Encrypting and decrypting
# https://raku.online/modules/text-caesar/#encrypting-and-decrypting
#
# Install what it needs, then run it:
#     rakupp install Text::Caesar
#     rakupp 02-keys.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Caesar;

for 0, 1, 25, 26, -3 -> $k {
    my $r = try encrypt($k, 'abc');
    say sprintf('key %3d -> %s', $k, $! ?? 'refused' !! $r);
}

# Output:
#     key   0 -> refused
#     key   1 -> BCD
#     key  25 -> ZAB
#     key  26 -> refused
#     key  -3 -> refused
