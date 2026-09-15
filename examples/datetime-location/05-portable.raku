#!/usr/bin/env rakupp
# DateTime::Location — Where the two engines differ
# https://raku.online/modules/datetime-location/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install DateTime::Location
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Location;

# the shape that works everywhere: both identifiers, a Num offset,
# and your own range check before you hand the numbers over
sub location(:$id!, :$name!, :$lat!, :$lon!, :$tz!) {
    die "latitude out of range: $lat"  unless -90  <= $lat <= 90;
    die "longitude out of range: $lon" unless -180 <= $lon <= 180;
    DateTime::Location.new(:$id, :$name, lat => $lat.Num, lon => $lon.Num,
                           timezone => $tz.Num)
}

my $l = location(id => 'EGLL', name => 'Heathrow', lat => 51.4706, lon => -0.4619, tz => 0);
say 'built : ', $l.name, ' at ', $l.lat, ', ', $l.lon, ' (UTC', $l.timezone.Int, ')';
my $bad = try location(id => 'X', name => 'X', lat => 1000, lon => 0, tz => 0);
say 'guard : ', $! ?? $!.message !! 'accepted';

# Output:
#     built : Heathrow at 51.4706, -0.4619 (UTC0)
#     guard : latitude out of range: 1000
