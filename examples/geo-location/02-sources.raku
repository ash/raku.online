#!/usr/bin/env rakupp
# Geo::Location — From JSON, or from the environment
# https://raku.online/modules/geo-location/#from-json-or-from-the-environment
#
# Install what it needs, then run it:
#     rakupp install Geo::Location
#     rakupp 02-sources.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Location;

my $j = Geo::Location.new(json => '{"lat":51.5,"lon":-0.125,"name":"Somewhere","id":7}');
say 'from JSON  : ', $j.lat, ', ', $j.lon, '  name=', $j.name, ' id=', $j.id;
say '  lat type : ', $j.lat.WHAT.^name;
say '';
say 'an unknown key is a hard die — the only strictness in the module,';
say 'and it is aimed at the safest input:';
my $r = try Geo::Location.new(json => '{"lat":1,"lon":2,"altitude":9}');
say '  {"altitude":9} -> ', $! ?? $!.message.lines.grep(*.trim).tail.trim !! 'accepted';
say '';
say 'GEO_LOCATION is read when it contains both "lat(" and "lon(" and is';
say 'longer than 12 characters — and leaves lat/lon as Str, not numbers.';
say 'JSON leaves them Rat. Downstream numeric code sees different types';
say 'depending on how the object was made.';

# Output:
#     from JSON  : 51.5, -0.125  name=Somewhere id=7
#       lat type : Rat
#     
#     an unknown key is a hard die — the only strictness in the module,
#     and it is aimed at the safest input:
#       {"altitude":9} -> FATAL: Unknown attribute 'altitude'
#     
#     GEO_LOCATION is read when it contains both "lat(" and "lon(" and is
#     longer than 12 characters — and leaves lat/lon as Str, not numbers.
#     JSON leaves them Rat. Downstream numeric code sees different types
#     depending on how the object was made.
