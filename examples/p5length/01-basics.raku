#!/usr/bin/env rakupp
# P5length — Using it
# https://raku.online/modules/p5length/#using-it
#
# Install what it needs, then run it:
#     rakupp install P5length
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5length;

say 'length("hello") = ', length('hello');
say 'length("")      = ', length('');
say 'length("héllo") = ', length("h\c[LATIN SMALL LETTER E WITH ACUTE]llo"),
    '   <- graphemes, as .chars counts them';
say '';
say 'a number goes through the Str coercion:';
say 'length(12345)   = ', length(12345);
say 'length(3.14)    = ', length(3.14);

# Output:
#     length("hello") = 5
#     length("")      = 0
#     length("héllo") = 5   <- graphemes, as .chars counts them
#     
#     a number goes through the Str coercion:
#     length(12345)   = 5
#     length(3.14)    = 4
