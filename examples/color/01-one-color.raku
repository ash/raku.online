#!/usr/bin/env rakupp
# Color — What it is for
# https://raku.online/modules/color/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install Color
#     rakupp 01-one-color.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Color;

my $c = Color.new('#ff8800');
say ~$c;
say $c.rgb;
say $c.to-string('rgb');
say $c.to-string('hsl');
say Color.new(:hsl[210, 80, 40]).to-string('hex');
say Color.new(r => 255, g => 136, b => 0) eqv $c;

# Output:
#     #FF8800
#     (255 136 0)
#     rgb(255, 136, 0)
#     hsl(32, 100, 50)
#     #1466B7
#     True
