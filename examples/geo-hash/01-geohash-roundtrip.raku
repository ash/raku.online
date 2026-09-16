#!/usr/bin/env rakupp
# Geo::Hash — Encoding and decoding
# https://raku.online/modules/geo-hash/#encoding-and-decoding
#
# Install what it needs, then run it:
#     rakupp install Geo::Hash
#     rakupp 01-geohash-roundtrip.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Hash;

# Tokyo Station, to eight characters
my $hash = geo-encode(35.6812e0, 139.7671e0, 8);
say $hash;

# …and back. Decoding returns a Coord, not a pair of numbers.
my $c = geo-decode($hash);
say $c.latitude.round(0.0001);
say $c.longitude.round(0.0001);

# Output:
#     xn76urx6
#     35.6813
#     139.7672
