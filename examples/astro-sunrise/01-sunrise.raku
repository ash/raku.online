#!/usr/bin/env rakupp
# Astro::Sunrise — Sunrise and sunset
# https://raku.online/modules/astro-sunrise/#sunrise-and-sunset
#
# Install what it needs, then run it:
#     rakupp install Astro::Sunrise
#     rakupp 01-sunrise.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Astro::Sunrise;

# Boston: longitude -71.0589, latitude 42.3601, UTC-5
my $date = Date.new(2024, 6, 21);
my ($rise, $set) = sunrise($date, -71.0589, 42.3601, -5);
say "Boston, midsummer  rise=$rise set=$set";
say 'return types       : ', $rise.^name, ' / ', $set.^name;
say '';
my ($dr, $ds) = sunrise(2024, 6, 21, -71.0589, 42.3601, -5);
say 'the year/month/day form gives DateTimes:';
say '  rise : ', $dr;
say '  set  : ', $ds;

# Output:
#     Boston, midsummer  rise=04:06 set=19:26
#     return types       : Str / Str
#     
#     the year/month/day form gives DateTimes:
#       rise : 2024-06-21T04:06:00Z
#       set  : 2024-06-21T19:26:00Z
