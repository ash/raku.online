#!/usr/bin/env rakupp
# Data::Generators — Words
# https://raku.online/ecosystem/data-generators/#words
#
# Install what it needs, then run it:
#     rakupp install Data::Generators
#     rakupp 03-word-types.raku
#
# Run under Raku++ 3.5.1 (dev build) and Rakudo 2026.06 every time the site is
# built; the build fails if the output below stops matching.

use Data::Generators;

my @common = random-word(5, type => 'common');
my @stop   = random-word(5, type => 'stopword');
say @common.elems + @stop.elems;
say so (@common, @stop).flat.all ~~ Str;
say so random-word(200, type => 'stopword').map(*.chars).max <= 15;

# Output:
#     10
#     True
#     True
