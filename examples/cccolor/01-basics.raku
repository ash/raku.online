#!/usr/bin/env rakupp
# CCColor — Converting
# https://raku.online/modules/cccolor/#converting
#
# Install what it needs, then run it:
#     rakupp install CCColor
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use CCColor;

for '#FF8800', 'FF8800', '#FF880080', '#0000FF' -> $hex {
    my @c = hex2rgba($hex);
    say sprintf('  %-12s -> (%s)  [%d %d %d %d]',
                $hex.raku, @c.map({ .round(0.0001) }).join(', '),
                |@c.map({ ($_ * 255).round }));
}
say '';
say 'the components are exact Rats, not floats:';
my @c = hex2rgba('#FF8800');
say '  types  : ', @c.map({ .WHAT.^name }).join(', ');
say '  green  : ', @c[1].raku, '  = 136/255';
say '';
say 'alpha defaults to 0xFF when the string carries only three bytes.';
say 'whitespace is stripped globally, so "# F F 8 8 0 0" parses too:';
say '  ', hex2rgba('# F F 8 8 0 0').map({ ($_ * 255).round }).join(' ');

# Output:
#       "#FF8800"    -> (1, 0.5333, 0, 1)  [255 136 0 255]
#       "FF8800"     -> (1, 0.5333, 0, 1)  [255 136 0 255]
#       "#FF880080"  -> (1, 0.5333, 0, 0.502)  [255 136 0 128]
#       "#0000FF"    -> (0, 0, 1, 1)  [0 0 255 255]
#     
#     the components are exact Rats, not floats:
#       types  : Rat, Rat, Rat, Rat
#       green  : <8/15>  = 136/255
#     
#     alpha defaults to 0xFF when the string carries only three bytes.
#     whitespace is stripped globally, so "# F F 8 8 0 0" parses too:
#       255 136 0 255
