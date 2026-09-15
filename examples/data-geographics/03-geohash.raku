#!/usr/bin/env rakupp
# Data::Geographics — The one thing to know
# https://raku.online/modules/data-geographics/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Data::Geographics
#     rakupp 03-geohash.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Geographics;
use Data::Geographics::GeoHash;

my ($lat, $lon) = 42.69, 23.31;
my $gh = geohash($lat, $lon, p => 8);
say 'geohash(42.69, 23.31, :p(8)) = ', $gh;
say '';
my %box = geohash-decode($gh);
say 'decoded box:';
for <latitude longitude> -> $axis {
    say sprintf('  %-10s min=%-14s max=%-14s min <= max ? %s',
                $axis, %box{$axis}<min>, %box{$axis}<max>,
                %box{$axis}<min> <= %box{$axis}<max>);
}
say '';
say 'the magnitudes are right; the labels are not. So the obvious';
say 'containment test reports FALSE for the very point that produced the';
say 'geohash:';
say '  as labelled : ',
    (%box<latitude><min> <= $lat <= %box<latitude><max>);
say '  swapped     : ',
    (%box<latitude><max> <= $lat <= %box<latitude><min>);
say '';
say 'geohash-neighbors is nevertheless CORRECT — it computes from the';
say 'same negative span and the sign cancels:';
say '  ', geohash("sx8df".Str, format => 'neighbors').sort.join(' ');

# Output:
#     geohash(42.69, 23.31, :p(8)) = sx8df7mz
#     
#     decoded box:
#       latitude   min=42.690125      max=42.6899529     min <= max ? False
#       longitude  min=23.310242      max=23.3098984     min <= max ? False
#     
#     the magnitudes are right; the labels are not. So the obvious
#     containment test reports FALSE for the very point that produced the
#     geohash:
#       as labelled : False
#       swapped     : True
#     
#     geohash-neighbors is nevertheless CORRECT — it computes from the
#     same negative span and the sign cancels:
#       sx8d9 sx8dc sx8dd sx8de sx8dg sx8e1 sx8e4 sx8e5
