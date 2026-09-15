#!/usr/bin/env rakupp
# EuclideanRhythm — Generating a bar
# https://raku.online/modules/euclideanrhythm/#generating-a-bar
#
# Install what it needs, then run it:
#     rakupp install EuclideanRhythm
#     rakupp 01-rhythm.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use EuclideanRhythm;

sub pattern($e) { $e.once.map({ $_ ?? 'x' !! '.' }).join }

for (16, 7), (8, 3), (16, 5), (13, 5), (12, 4), (8, 8), (8, 0), (5, 1) -> ($s, $f) {
    my $e = EuclideanRhythm.new(slots => $s, fills => $f);
    say sprintf('%2d slots %2d fills  %-16s  (length %d, %d hits)',
        $s, $f, pattern($e), $e.once.elems, $e.once.grep(?*).elems);
}

# Output:
#     16 slots  7 fills  x..x.x.x..x.x.x.  (length 16, 7 hits)
#      8 slots  3 fills  x..x..x.          (length 8, 3 hits)
#     16 slots  5 fills  .x..x..x..x..x..  (length 16, 5 hits)
#     13 slots  5 fills  .x.x..x.x..x.     (length 13, 5 hits)
#     12 slots  4 fills  x..x..x..x..      (length 12, 4 hits)
#      8 slots  8 fills  xxxxxxxx          (length 8, 8 hits)
#      8 slots  0 fills  ........          (length 8, 0 hits)
#      5 slots  1 fills  x....             (length 5, 1 hits)
