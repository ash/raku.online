#!/usr/bin/env rakupp
# Statistics::Distributions — Your first draw
# https://raku.online/ecosystem/statistics-distributions/#your-first-draw
#
# Install what it needs, then run it:
#     rakupp install Statistics::Distributions
#     rakupp 03-draw-shape.raku
#
# Run under Raku++ 3.5.1 (dev build) and Rakudo 2026.06 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::Distributions;

my @s = random-variate(NormalDistribution.new(:mean(170), :sd(8)), 1000);

say @s.elems;                      # how many you asked for
say @s.head.WHAT;                  # what each one is
say 168 < @s.sum / @s.elems < 172; # the mean lands where you set it

# Output:
#     1000
#     (Num)
#     True
