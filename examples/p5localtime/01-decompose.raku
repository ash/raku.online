#!/usr/bin/env rakupp
# P5localtime — Fields, or a string
# https://raku.online/modules/p5localtime/#fields-or-a-string
#
# Install what it needs, then run it:
#     rakupp install P5localtime
#     rakupp 01-decompose.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5localtime;

my @g = gmtime(1_000_000_000);
say @g.elems;
say @g[0..8].join(' ');

my ($sec, $min, $hour, $mday, $mon, $year) = @g;
say "{$year + 1900}-{$mon + 1}-$mday {$hour}:{$min}:{$sec}";

say gmtime(Scalar, 1_000_000_000);
say gmtime(Scalar, 0);
say gmtime(0)[9], ' ', gmtime(0)[10];

# Output:
#     11
#     40 46 1 9 8 101 0 251 0
#     2001-9-9 1:46:40
#     Sun Sep  9 01:46:40 2001
#     Thu Jan  1 00:00:00 1970
#     0 UTC
