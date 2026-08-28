#!/usr/bin/env rakupp
# Color — This, but darker
# https://raku.online/modules/color/#this-but-darker
#
# Install what it needs, then run it:
#     rakupp install Color
#     rakupp 02-palette.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Color;

my $brand = Color.new('#ff8800');
say $brand.darken(20).to-string('hex');
say $brand.lighten(20).to-string('hex');
say $brand.desaturate(50).to-string('hex');
say $brand.invert.to-string('hex');

# Output:
#     #995100
#     #FFB766
#     #BF833F
#     #0077FF
