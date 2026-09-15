#!/usr/bin/env rakupp
# Color::Scheme — The seventeen names
# https://raku.online/modules/color-scheme/#the-seventeen-names
#
# Install what it needs, then run it:
#     rakupp install Color::Scheme
#     rakupp 03-names.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Color::Scheme;

say Color::Scheme::color-scheme-angles.keys.sort.join("\n");

# Output:
#     analogous
#     clash
#     five-tone-a
#     five-tone-b
#     five-tone-cs
#     five-tone-ds
#     five-tone-es
#     four-tone-ccw
#     four-tone-cw
#     neutral
#     six-tone-ccw
#     six-tone-cw
#     split-complementary
#     split-complementary-ccw
#     split-complementary-cw
#     tetradic
#     triadic
