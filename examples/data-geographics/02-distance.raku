#!/usr/bin/env rakupp
# Data::Geographics — Distance
# https://raku.online/modules/data-geographics/#distance
#
# Install what it needs, then run it:
#     rakupp install Data::Geographics
#     rakupp 02-distance.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Geographics;

my ($sofia-lat, $sofia-lon) = 42.69, 23.31;
my ($paris-lat, $paris-lon) = 48.85,  2.35;

say 'geo-distance takes four positionals, two pairs, or one 4-element list:';
say '  metres     : ', geo-distance($sofia-lat, $sofia-lon, $paris-lat, $paris-lon).round;
say '  kilometres : ',
    geo-distance($sofia-lat, $sofia-lon, $paris-lat, $paris-lon, 'kilometers').round;
say '  miles      : ',
    geo-distance($sofia-lat, $sofia-lon, $paris-lat, $paris-lon, 'miles').round;
say '';
sub haversine($la1, $lo1, $la2, $lo2, $R) {
    my ($p1, $p2) = ($la1, $la2).map(* * pi / 180);
    my $dp = ($la2 - $la1) * pi / 180;
    my $dl = ($lo2 - $lo1) * pi / 180;
    my $a = sin($dp/2)**2 + cos($p1) * cos($p2) * sin($dl/2)**2;
    2 * $R * asin(sqrt($a))
}
say 'against a haversine with the EQUATORIAL radius 6378140 m:';
say '  ', haversine($sofia-lat, $sofia-lon, $paris-lat, $paris-lon, 6378140).round;
say 'and with the usual MEAN radius 6371000 m:';
say '  ', haversine($sofia-lat, $sofia-lon, $paris-lat, $paris-lon, 6371000).round;
say '';
say 'the module uses the equatorial radius, so its distances run about';
say '0.11% long against the conventional answer.';
say '';
say 'an unrecognised unit is a clean die:';
my $r = try geo-distance(0, 0, 1, 1, 'furlongs');
say '  units => "furlongs" -> ', $! ?? 'refused' !! $r;

# Output:
#     geo-distance takes four positionals, two pairs, or one 4-element list:
#       metres     : 1758767
#       kilometres : 1759
#       miles      : 1093
#     
#     against a haversine with the EQUATORIAL radius 6378140 m:
#       1758767
#     and with the usual MEAN radius 6371000 m:
#       1756798
#     
#     the module uses the equatorial radius, so its distances run about
#     0.11% long against the conventional answer.
#     
#     an unrecognised unit is a clean die:
#       units => "furlongs" -> refused
