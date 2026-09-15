#!/usr/bin/env rakupp
# Geo::Location — No validation, and rounded seconds
# https://raku.online/modules/geo-location/#no-validation-and-rounded-seconds
#
# Install what it needs, then run it:
#     rakupp install Geo::Location
#     rakupp 04-validation.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::Location;

my $wild = Geo::Location.new(lat => 999, lon => -4000);
say 'lat => 999, lon => -4000 is accepted : ', $wild.location(:bare);
say '  and rendered : ', $wild.location(format => 'dms', :bare);
say '';
say 'the private !check-lat-lon exists, its body is comments, and TWEAK';
say 'has a bare `return;` on the line BEFORE the call — dead code.';
say '';
say 'the dms renderer ROUNDS minutes instead of truncating, so seconds';
say 'can come out negative, and minutes can come out as 60:';
for 30.361666666, 1.9999 -> $lat {
    my $g = Geo::Location.new(:$lat, lon => 0);
    say sprintf('  lat %-14s -> %-14s  rst %s',
                $lat, $g.lat-dms, $g.lat-rst);
}
say '';
say 'riseset-format shares that rounding, so the rise/set string is off';
say 'by up to half a minute of arc and can read …N60.';

# Output:
#     lat => 999, lon => -4000 is accepted : 999 -4000
#       and rendered : N999d0m0s W4000d0m0s
#     
#     the private !check-lat-lon exists, its body is comments, and TWEAK
#     has a bare `return;` on the line BEFORE the call — dead code.
#     
#     the dms renderer ROUNDS minutes instead of truncating, so seconds
#     can come out negative, and minutes can come out as 60:
#       lat 30.361666666   -> N30d22m-18s     rst 30N22
#       lat 1.9999         -> N1d60m0s        rst 1N60
#     
#     riseset-format shares that rounding, so the rise/set string is off
#     by up to half a minute of arc and can read …N60.
