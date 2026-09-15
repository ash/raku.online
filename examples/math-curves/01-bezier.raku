#!/usr/bin/env rakupp
# Math::Curves — Evaluating a curve
# https://raku.online/modules/math-curves/#evaluating-a-curve
#
# Install what it needs, then run it:
#     rakupp install Math::Curves
#     rakupp 01-bezier.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Curves;

say 'linear (two control points), from 0 to 10:';
for 0/1, 1/4, 1/2, 3/4, 1/1 -> $t {
    say sprintf('  t=%-5s -> %s', $t.raku, bézier($t, 0, 10).raku);
}
say '';
say 'quadratic (three), with the middle point pulled to 10:';
for 0/1, 1/4, 1/2, 3/4, 1/1 -> $t {
    say sprintf('  t=%-5s -> %s', $t.raku, bézier($t, 0, 10, 0).raku);
}
say '';
say 'cubic (four), the usual easing shape:';
for 0/1, 1/4, 1/2, 3/4, 1/1 -> $t {
    say sprintf('  t=%-5s -> %s', $t.raku, bézier($t, 0, 0, 10, 10).raku);
}

# Output:
#     linear (two control points), from 0 to 10:
#       t=0.0   -> 0.0
#       t=0.25  -> 2.5
#       t=0.5   -> 5.0
#       t=0.75  -> 7.5
#       t=1.0   -> 10.0
#     
#     quadratic (three), with the middle point pulled to 10:
#       t=0.0   -> 0.0
#       t=0.25  -> 3.75
#       t=0.5   -> 5.0
#       t=0.75  -> 3.75
#       t=1.0   -> 0.0
#     
#     cubic (four), the usual easing shape:
#       t=0.0   -> 0.0
#       t=0.25  -> 1.5625
#       t=0.5   -> 5.0
#       t=0.75  -> 8.4375
#       t=1.0   -> 10.0
