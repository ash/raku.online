#!/usr/bin/env rakupp
# QueryOS — The one thing to know
# https://raku.online/modules/queryos/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install QueryOS
#     rakupp 03-vnum-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use QueryOS;

for '10.2', '10.9', '10.15', '10.15.7', '11.0' -> $v {
    say sprintf('  %-9s vnum = %s', $v, os-version-parts($v)<vnum>);
}
say '';
my @vers = <10.2 10.9 10.15 10.15.7 11.0>;
say 'sorted by vnum  : ', @vers.sort({ os-version-parts($_)<vnum> }).join(' ');
say 'true chronology : 10.2 10.9 10.15 10.15.7 11.0';

# Output:
#       10.2      vnum = 10.2
#       10.9      vnum = 10.9
#       10.15     vnum = 10.15
#       10.15.7   vnum = 10.157
#       11.0      vnum = 11
#     
#     sorted by vnum  : 10.15 10.15.7 10.2 10.9 11.0
#     true chronology : 10.2 10.9 10.15 10.15.7 11.0
