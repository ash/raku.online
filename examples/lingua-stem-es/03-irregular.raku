#!/usr/bin/env rakupp
# Lingua::Stem::Es — The one thing to know
# https://raku.online/modules/lingua-stem-es/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::Stem::Es
#     rakupp 03-irregular.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Stem::Es;

say 'ser  : ', <ser es son fui era>.map({ stem($_) }).join(' ');
say 'tener: ', <tener tengo tiene tuvo>.map({ stem($_) }).join(' ');
say 'ir   : ', <ir voy fue>.map({ stem($_) }).join(' ');
say '';
say 'five distinct tokens for the present and past of ser.';

# Output:
#     ser  : ser es son fui era
#     tener: ten teng tien tuv
#     ir   : ir voy fue
#     
#     five distinct tokens for the present and past of ser.
