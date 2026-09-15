#!/usr/bin/env rakupp
# Geo::Location — Building and rendering
# https://raku.online/modules/geo-location/#building-and-rendering
#
# Install what it needs, then run it:
#     rakupp install Geo::Location
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Location;

my $g = Geo::Location.new(lat => 51.4775, lon => -0.0014, name => 'Greenwich');

say 'name              : ', $g.name;
say 'lat / lon         : ', $g.lat, ' / ', $g.lon;
say '';
say 'location()        : ', $g.location;
say 'location(:bare)   : ', $g.location(:bare);
say 'dms               : ', $g.location(format => 'dms');
say 'dms, bare         : ', $g.location(format => 'dms', :bare);
say 'rst               : ', $g.location(format => 'rst');
say 'riseset-format    : ', $g.riseset-format;
say '';
say ':format is matched with /:i ^dms/, /:i ^dec/ and /:i ^rst/ —';
say 'anything else falls back to decimal without complaint:';
say '  format => "nonsense" -> ', $g.location(format => 'nonsense');

# Output:
#     name              : Greenwich
#     lat / lon         : 51.4775 / -0.0014
#     
#     location()        : lat: 51.4775, lon: -0.0014
#     location(:bare)   : 51.4775 -0.0014
#     dms               : lat: N51d29m-21s, lon: W0d0m5s
#     dms, bare         : N51d29m-21s W0d0m5s
#     rst               : lat: 51N29, lon: 0W0
#     riseset-format    : 51N29 0W0
#     
#     :format is matched with /:i ^dms/, /:i ^dec/ and /:i ^rst/ —
#     anything else falls back to decimal without complaint:
#       format => "nonsense" -> lat: 51.4775, lon: -0.0014
