#!/usr/bin/env rakupp
# CCColor — The CSS shorthand is wrong, not unsupported
# https://raku.online/modules/cccolor/#the-css-shorthand-is-wrong-not-unsupported
#
# Install what it needs, then run it:
#     rakupp install CCColor
#     rakupp 03-shorthand.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use CCColor;

say 'a 1..4 character string is read as one hex NIBBLE per channel:';
for '#F80', '#FFF', '#ABCD', '#1' -> $hex {
    say sprintf('  %-8s -> [%s]', $hex,
                hex2rgba($hex).map({ ($_ * 255).round }).join(' '));
}
say '';
say '#FFF is near-black, not white; #F80 is [15 8 0], not [255 136 0].';
say 'and #ABCD is read as RGBA nibbles, so its alpha is 13/255 — almost';
say 'transparent.';
say '';
say 'expand the shorthand yourself before calling:';
sub expand(Str $h is copy) {
    $h .= subst('#', '');
    $h = $h.comb.map({ $_ x 2 }).join if $h.chars == 3;
    hex2rgba($h.uc)
}
say '  expand("#f80") -> [', expand('#f80').map({ ($_ * 255).round }).join(' '), ']';

# Output:
#     a 1..4 character string is read as one hex NIBBLE per channel:
#       #F80     -> [15 8 0 255]
#       #FFF     -> [15 15 15 255]
#       #ABCD    -> [10 11 12 13]
#       #1       -> [1 0 0 255]
#     
#     #FFF is near-black, not white; #F80 is [15 8 0], not [255 136 0].
#     and #ABCD is read as RGBA nibbles, so its alpha is 13/255 — almost
#     transparent.
#     
#     expand the shorthand yourself before calling:
#       expand("#f80") -> [255 136 0 255]
