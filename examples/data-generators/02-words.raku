#!/usr/bin/env rakupp
# Data::Generators — Words
# https://raku.online/ecosystem/data-generators/#words
#
# Install what it needs, then run it:
#     rakupp install Data::Generators
#     rakupp 02-words.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Generators;

say random-word(1000).elems;
say so random-word(1000).all ~~ Str;
say random-word(1000).unique.elems > 500;

# Output:
#     1000
#     True
#     True
