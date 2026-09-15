#!/usr/bin/env rakupp
# Color::Scheme — Your own angles
# https://raku.online/modules/color-scheme/#your-own-angles
#
# Install what it needs, then run it:
#     rakupp install Color::Scheme
#     rakupp 02-angles.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Color;
use Color::Scheme;

my $base = Color.new('#FF0000');

say 'explicit [0, 180]  : ', color-scheme($base, [0, 180]).map(*.to-string('hex')).join(' ');
say 'explicit [0, 120, 240] : ',
    color-scheme($base, [0, 120, 240]).map(*.to-string('hex')).join(' ');
say '';
say 'angles wrap, and accept negatives and fractions:';
for 360, -120, 720, 12.5 -> $a {
    say sprintf('  %-6s -> %s', $a, color-scheme($base, [$a]).map(*.to-string('hex')).join);
}
say '';
say 'returns an ', color-scheme($base, [0, 180]).^name, ' of ',
    color-scheme($base, [0, 180])[0].^name;

# Output:
#     explicit [0, 180]  : #FF0000 #00FFFF
#     explicit [0, 120, 240] : #FF0000 #00FF00 #0000FF
#     
#     angles wrap, and accept negatives and fractions:
#       360    -> #FF0000
#       -120   -> #0000FF
#       720    -> #FF0000
#       12.5   -> #FF3500
#     
#     returns an Array of Color
