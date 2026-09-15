#!/usr/bin/env rakupp
# DateTime::Location — Building one
# https://raku.online/modules/datetime-location/#building-one
#
# Install what it needs, then run it:
#     rakupp install DateTime::Location
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Location;

my $loc = DateTime::Location.new(
    id       => 'KDCA',
    name     => 'Washington National',
    lat      => 38.8521,
    lon      => -77.0377,
    timezone => -5e0,
    city     => 'Arlington',
    state    => 'VA',
    country  => 'US',
    region   => 'NA',
);

for <id name lat lon timezone state country region notes dst-start dst-end> -> $f {
    say sprintf('  %-10s %s', $f, $loc."$f"().raku);
}

# Output:
#       id         "KDCA"
#       name       "Washington National"
#       lat        38.8521
#       lon        -77.0377
#       timezone   -5e0
#       state      "VA"
#       country    "US"
#       region     "NA"
#       notes      Any
#       dst-start  Any
#       dst-end    Any
