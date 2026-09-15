#!/usr/bin/env rakupp
# EuclideanRhythm — The repeating form
# https://raku.online/modules/euclideanrhythm/#the-repeating-form
#
# Install what it needs, then run it:
#     rakupp install EuclideanRhythm
#     rakupp 02-list.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use EuclideanRhythm;

my $e = EuclideanRhythm.new(slots => 8, fills => 3);

say 'once  : ', $e.once.map({ $_ ?? 'x' !! '.' }).join, '   (', $e.once.elems, ' slots)';
say 'list  : ', $e.list[^24].map({ $_ ?? 'x' !! '.' }).join, '   (first 24 of an endless Seq)';
say '';
say 'slots : ', $e.slots, '   fills : ', $e.fills;

# Output:
#     once  : x..x..x.   (8 slots)
#     list  : x..x..x.x..x..x.x..x..x.   (first 24 of an endless Seq)
#     
#     slots : 8   fills : 3
