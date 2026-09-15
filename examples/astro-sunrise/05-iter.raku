#!/usr/bin/env rakupp
# Astro::Sunrise — Where the two engines differ
# https://raku.online/modules/astro-sunrise/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Astro::Sunrise
#     rakupp 05-iter.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Astro::Sunrise;

my $date = Date.new(2024, 6, 21);
my ($p, $q) = sunrise($date, -71.0589, 42.3601, -5);
my ($r, $s) = sunrise($date, -71.0589, 42.3601, -5, -0.833, :iter);
say "plain    : rise=$p set=$q";
say "iterated : rise=$r set=$s";

# Output:
#     plain    : rise=04:06 set=19:26
#     iterated : rise=04:07 set=19:25
