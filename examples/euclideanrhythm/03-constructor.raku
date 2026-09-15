#!/usr/bin/env rakupp
# EuclideanRhythm — The constructor
# https://raku.online/modules/euclideanrhythm/#the-constructor
#
# Install what it needs, then run it:
#     rakupp install EuclideanRhythm
#     rakupp 03-constructor.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use EuclideanRhythm;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-28s %s', $label, $! ?? 'refused' !! 'accepted');
}

attempt 'fills > slots',   { EuclideanRhythm.new(slots => 4, fills => 9) };
attempt 'fills == slots',  { EuclideanRhythm.new(slots => 4, fills => 4) };
attempt 'fills == 0',      { EuclideanRhythm.new(slots => 4, fills => 0) };
attempt 'an unknown named argument', { EuclideanRhythm.new(slots => 4, fills => 2, wibble => 1) };

# Output:
#     fills > slots                refused
#     fills == slots               accepted
#     fills == 0                   accepted
#     an unknown named argument    accepted
