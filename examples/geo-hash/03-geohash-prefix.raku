#!/usr/bin/env rakupp
# Geo::Hash — The prefix property
# https://raku.online/modules/geo-hash/#the-prefix-property
#
# Install what it needs, then run it:
#     rakupp install Geo::Hash
#     rakupp 03-geohash-prefix.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Hash;

my @hashes = (4, 6, 8).map: { geo-encode(35.6812e0, 139.7671e0, $_) };
say @hashes.join(' ');
say @hashes[2].starts-with(@hashes[0]);

# Output:
#     xn76 xn76ur xn76urx6
#     True
