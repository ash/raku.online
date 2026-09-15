#!/usr/bin/env rakupp
# Geo::Location — The one thing to know
# https://raku.online/modules/geo-location/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Geo::Location
#     rakupp 03-one-coordinate.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Location;

my $half = Geo::Location.new(lat => 10);
say 'Geo::Location.new(lat => 10):';
say '  lat  : ', $half.lat;
say '  lon  : ', $half.lon;
say '  name : ', $half.name;
say '';
say 'TWEAK`s first branch fires only when BOTH are defined. A single';
say 'coordinate falls through to the defaults branch, which OVERWRITES';
say 'the one you gave. So the most likely typo in a geolocation program —';
say 'forgetting one number, or misspelling one named argument — does not';
say 'raise, does not warn, and quietly relocates you.';
say '';
say 'require both yourself:';
sub at(:$lat!, :$lon!, *%rest) { Geo::Location.new(:$lat, :$lon, |%rest) }
my $ok = at(lat => 51.4775, lon => -0.0014, name => 'Greenwich');
say '  at(:lat, :lon) -> ', $ok.location(:bare);
my $bad = try at(lat => 10);
say '  at(:lat) alone -> ', $! ?? 'refused' !! 'accepted';

# Output:
#     Geo::Location.new(lat => 10):
#       lat  : 30.35616
#       lon  : -87.17095
#       name : Gulf Breeze, FL, USA
#     
#     TWEAK`s first branch fires only when BOTH are defined. A single
#     coordinate falls through to the defaults branch, which OVERWRITES
#     the one you gave. So the most likely typo in a geolocation program —
#     forgetting one number, or misspelling one named argument — does not
#     raise, does not warn, and quietly relocates you.
#     
#     require both yourself:
#       at(:lat, :lon) -> 51.4775 -0.0014
#       at(:lat) alone -> refused
