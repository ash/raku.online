#!/usr/bin/env rakupp
# Noise::Simplex — The one thing to know
# https://raku.online/modules/noise-simplex/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Noise::Simplex
#     rakupp 03-tiling.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Noise::Simplex;

my &n2 = Simplex.new(seed => 42).create-noise2d;
my $period = 256 / sqrt(3);
say 'claimed period along the diagonal : ', $period.round(0.0001);
say '';
my @diffs = (^20).map({
    my $t = $_ * 3.1;
    abs(n2($t, $t) - n2($t + $period, $t + $period))
});
say '  largest |f(p) - f(p + period)| : ', @diffs.max < 1e-9 ?? 'below 1e-9' !! @diffs.max;
say '  at HALF the period it differs  : ',
    abs(n2(1.0, 1.0) - n2(1 + $period/2, 1 + $period/2)) > 1e-6;
say '';
say 'the skewed lattice index is masked with +& 255, and there is no';
say 'option to change it. For terrain sampled over a few hundred units';
say 'this is invisible; over a few thousand the same landscape comes back.';
say '';
say 'any scaling of the input scales the period with it — a';
say 'noise(x/100, y/100) field repeats every ~14780 world units.';

# Output:
#     claimed period along the diagonal : 147.8017
#     
#       largest |f(p) - f(p + period)| : below 1e-9
#       at HALF the period it differs  : True
#     
#     the skewed lattice index is masked with +& 255, and there is no
#     option to change it. For terrain sampled over a few hundred units
#     this is invisible; over a few thousand the same landscape comes back.
#     
#     any scaling of the input scales the period with it — a
#     noise(x/100, y/100) field repeats every ~14780 world units.
