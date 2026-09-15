#!/usr/bin/env rakupp
# Moonphase — The one thing to know
# https://raku.online/modules/moonphase/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Moonphase
#     rakupp 03-negative.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Moonphase;

my $new = 1503354360;    # the 2017-08-21 new moon
say 'hourly sweep across it:';
for -2, -1, 0, 1, 2 -> $h {
    my $p = moonphase($new + $h * 3600);
    say sprintf('  %+3d h  %14.8f rad   in 0..2pi? %s', $h, $p, (0 <= $p < 2 * pi));
}
say '';
say 'the cause is fixangle($a) { $a mod 360 }. Raku`s infix:<mod> is NOT %';
say 'for Reals — for a non-integral negative value it is the identity:';
for -1, -0.5, -0.027 -> $v {
    say sprintf('  %-8s mod 360 = %-10s   %% 360 = %s', $v, $v mod 360, $v % 360);
}
say '';
say 'so normalise it yourself: $p % (2 * pi)';
say '  normalised at the new moon: ', (moonphase($new) % (2 * pi)).round(0.000001);

# Output:
#     hourly sweep across it:
#        -2 h      0.01902130 rad   in 0..2pi? True
#        -1 h      0.02859970 rad   in 0..2pi? True
#        +0 h      0.03816906 rad   in 0..2pi? True
#        +1 h      0.04772927 rad   in 0..2pi? True
#        +2 h      0.05728022 rad   in 0..2pi? True
#     
#     the cause is fixangle($a) { $a mod 360 }. Raku`s infix:<mod> is NOT %
#     for Reals — for a non-integral negative value it is the identity:
#       -1       mod 360 = 359          % 360 = 359
#       -0.5     mod 360 = -0.5         % 360 = 359.5
#       -0.027   mod 360 = -0.027       % 360 = 359.973
#     
#     so normalise it yourself: $p % (2 * pi)
#       normalised at the new moon: 0.038169
