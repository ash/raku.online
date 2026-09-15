#!/usr/bin/env rakupp
# Data::Geographics — Where the two engines differ
# https://raku.online/modules/data-geographics/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Data::Geographics
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Geographics;

say 'the shapes that behave identically on both engines:';
say '  country-data($name)<$name><Field>';
say '  city-data($city) / city-data([$country, Whatever, Whatever])';
say '  geo-distance(…) in any of its argument forms';
say '  geohash($lat, $lon, :p($n))  and  geohash($gh, format => "neighbors")';
say '';
say 'a bare Str spec to city-data searches the CITY column only:';
say '  city-data("Bulgaria").elems          : ', city-data('Bulgaria').elems;
say '  city-data(["Bulgaria", *, *]).elems  : ',
    city-data(['Bulgaria', Whatever, Whatever]).elems;
say '';
say 'and city-data(Whatever) dies even though city-data() with no';
say 'arguments returns everything.';
say '';
say 'one last thing worth knowing before you deploy: META declares';
say '"depends": [] while the module does `use JSON::Fast`. It can install';
say 'into a store where it will not load.';

# Output:
#     the shapes that behave identically on both engines:
#       country-data($name)<$name><Field>
#       city-data($city) / city-data([$country, Whatever, Whatever])
#       geo-distance(…) in any of its argument forms
#       geohash($lat, $lon, :p($n))  and  geohash($gh, format => "neighbors")
#     
#     a bare Str spec to city-data searches the CITY column only:
#       city-data("Bulgaria").elems          : 0
#       city-data(["Bulgaria", *, *]).elems  : 261
#     
#     and city-data(Whatever) dies even though city-data() with no
#     arguments returns everything.
#     
#     one last thing worth knowing before you deploy: META declares
#     "depends": [] while the module does `use JSON::Fast`. It can install
#     into a store where it will not load.
