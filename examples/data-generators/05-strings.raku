#!/usr/bin/env rakupp
# Data::Generators — Strings with a shape
# https://raku.online/ecosystem/data-generators/#strings-with-a-shape
#
# Install what it needs, then run it:
#     rakupp install Data::Generators
#     rakupp 05-strings.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Generators;

my @s = random-string(100, chars => 4, ranges => ["a".."f", "0".."9"]);
say @s.elems;
say so @s.map(*.chars).all == 4;
say so @s.join.comb.all ~~ /<[a..f 0..9]>/;

# Output:
#     100
#     True
#     True
