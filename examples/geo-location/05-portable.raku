#!/usr/bin/env rakupp
# Geo::Location — Where the two engines differ
# https://raku.online/modules/geo-location/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Geo::Location
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Location;

# check before you render, and both engines agree
my $j = Geo::Location.new(json => '{"name":"nowhere"}');
say 'a JSON object with no coordinates:';
say '  lat defined ? ', $j.lat.defined;
say '  safe to render ? ', ($j.lat.defined && $j.lon.defined);
say '';
say 'and two subs that are NOT imported by a plain `use`:';
say '  convert-lat and convert-lon need `use Geo::Location :convert-lat,';
say '  :convert-lon` — and both are empty stubs that always return Nil,';
say '  so there is no reason to import them.';

# Output:
#     a JSON object with no coordinates:
#       lat defined ? False
#       safe to render ? False
#     
#     and two subs that are NOT imported by a plain `use`:
#       convert-lat and convert-lon need `use Geo::Location :convert-lat,
#       :convert-lon` — and both are empty stubs that always return Nil,
#       so there is no reason to import them.
