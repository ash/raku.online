#!/usr/bin/env rakupp
# Data::Generators — What it is for
# https://raku.online/ecosystem/data-generators/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install Data::Generators
#     rakupp 01-tour.raku
#
# Run under Raku++ 3.5.1 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use Data::Generators;

say random-word(4);
say random-pet-name(3);
say random-string(2, chars => 8, ranges => ["A".."Z", "0".."9"]);
say random-real((0, 100), 3).map(*.fmt('%.1f'));

# One run printed:
#     (remotely kitten roundelay ankylotic)
#     (Walter Sweetie Sasha)
#     (O72P0U5P PS4AVECI)
#     (12.3 87.4 55.0)
