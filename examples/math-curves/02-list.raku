#!/usr/bin/env rakupp
# Math::Curves — The list form and the parameter range
# https://raku.online/modules/math-curves/#the-list-form-and-the-parameter-range
#
# Install what it needs, then run it:
#     rakupp install Math::Curves
#     rakupp 02-list.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Curves;

say 'a list of control points : ', bézier(1/2, (0, 10, 0)).raku;
say '';
say 't must be in 0..1 — the subset enforces it:';
for 0/1, 1/1, 3/2, -1/2 -> $t {
    my $r = try bézier($t, 0, 10);
    say sprintf('  t=%-6s -> %s', $t.raku, $r.defined ?? $r.Str !! 'refused');
}

# Output:
#     a list of control points : 5.0
#     
#     t must be in 0..1 — the subset enforces it:
#       t=0.0    -> 0
#       t=1.0    -> 10
#       t=1.5    -> refused
#       t=-0.5   -> refused
