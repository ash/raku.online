#!/usr/bin/env rakupp
# Text::Diff::Sift4 — Tuning the two knobs
# https://raku.online/modules/text-diff-sift4/#tuning-the-two-knobs
#
# Install what it needs, then run it:
#     rakupp install Text::Diff::Sift4
#     rakupp 02-knobs.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Diff::Sift4;

my ($a, $b) = 'abcdefghijklm', 'mlkjihgfedcba';

say 'defaults            : ', sift4($a, $b);
say 'maxOffset 1         : ', sift4($a, $b, 1);
say 'maxOffset 12        : ', sift4($a, $b, 12);
say '';
say 'maxDistance sweep 0..6:';
say '  ', (0..6).map({ "md=$_:" ~ sift4($a, $b, 10, $_) }).join('  ');

# Output:
#     defaults            : 9
#     maxOffset 1         : 11
#     maxOffset 12        : 8
#     
#     maxDistance sweep 0..6:
#       md=0:9  md=1:2  md=2:3  md=3:4  md=4:5  md=5:6  md=6:7
