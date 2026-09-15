#!/usr/bin/env rakupp
# DateTime::Location — The accessor that is not one
# https://raku.online/modules/datetime-location/#the-accessor-that-is-not-one
#
# Install what it needs, then run it:
#     rakupp install DateTime::Location
#     rakupp 02-city.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Location;

my $loc = DateTime::Location.new(
    id => 'X', name => 'X', lat => 0e0, lon => 0e0, timezone => 0e0,
    city => 'Arlington');
my $r = try $loc.city;
say '$loc.city          -> ', $! ?? 'threw' !! $r.raku;
say '$loc.city("other") -> ', $loc.city('other').raku;
say '';
say 'a `method city($city) { }` at the end of the file REPLACES the';
say 'generated accessor. The value you passed as :city is stored and is';
say 'unreachable through any public method. `city` is the only field';
say 'affected — every other one reads back normally.';

# Output:
#     $loc.city          -> threw
#     $loc.city("other") -> Nil
#     
#     a `method city($city) { }` at the end of the file REPLACES the
#     generated accessor. The value you passed as :city is stored and is
#     unreachable through any public method. `city` is the only field
#     affected — every other one reads back normally.
