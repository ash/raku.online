#!/usr/bin/env rakupp
# Astro::Sunrise — The one thing to know
# https://raku.online/modules/astro-sunrise/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Astro::Sunrise
#     rakupp 04-order-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Astro::Sunrise;

my $date = Date.new(2024, 6, 21);

# Rome is latitude 41.90 N, longitude 12.50 E. Both numbers are legal
# latitudes, so nothing can detect the transposition.
my ($a, $b) = sunrise($date, 41.90, 12.50, 2);   # latitude first: wrong
my ($c, $d) = sunrise($date, 12.50, 41.90, 2);   # longitude first: right

say "latitude first (wrong)  : rise=$a set=$b";
say "longitude first (right) : rise=$c set=$d";
say 'no warning, no exception — both look like plausible clock times';

# Output:
#     latitude first (wrong)  : rise=04:47 set=17:41
#     longitude first (right) : rise=05:33 set=20:50
#     no warning, no exception — both look like plausible clock times
