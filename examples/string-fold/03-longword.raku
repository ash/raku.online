#!/usr/bin/env rakupp
# String::Fold — The one thing to know
# https://raku.online/modules/string-fold/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install String::Fold
#     rakupp 03-longword.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use String::Fold;

my $r = fold('supercalifragilistic', :width(8));
say 'lines       : ', $r.lines.elems;
say 'first line  : ', $r.lines[0].raku;
say 'second line : ', $r.lines[1].raku;
say '';
say 'and the same for any text whose FIRST word overflows:';
say fold('hello world', :width(1)).lines.map(*.raku).join(' ');

# Output:
#     lines       : 2
#     first line  : ""
#     second line : "supercalifragilistic"
#     
#     and the same for any text whose FIRST word overflows:
#     "" "hello" "world"
