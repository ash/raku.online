#!/usr/bin/env rakupp
# Geo::Hash — Precision is the length of the string
# https://raku.online/modules/geo-hash/#precision-is-the-length-of-the-string
#
# Install what it needs, then run it:
#     rakupp install Geo::Hash
#     rakupp 02-geohash-precision.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Hash;

for 1, 3, 5, 7 -> $p {
    my $h = geo-encode(35.6812e0, 139.7671e0, $p);
    my $c = geo-decode($h);
    say $h.fmt('%-8s'), ' ', ($c.north - $c.south).round(0.000001), '° tall';
}

# Output:
#     x        45° tall
#     xn7      1.40625° tall
#     xn76u    0.043945° tall
#     xn76urx  0.001373° tall
