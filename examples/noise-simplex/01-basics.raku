#!/usr/bin/env rakupp
# Noise::Simplex — Sampling a field
# https://raku.online/modules/noise-simplex/#sampling-a-field
#
# Install what it needs, then run it:
#     rakupp install Noise::Simplex
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Noise::Simplex;

my $s = Simplex.new(seed => 42);
my &n2 = $s.create-noise2d;

say 'a 5x5 grid at 0.5 spacing:';
for ^5 -> $y {
    say '  ', (^5).map({ sprintf('%+7.4f', n2($_ * 0.5, $y * 0.5)) }).join(' ');
}
say '';
say 'create-noise2d returns a ', &n2.WHAT.^name, ' taking ($x, $y).';
say 'create-noise3d gives you a three-argument one.';

# Output:
#     a 5x5 grid at 0.5 spacing:
#       +0.0000 +0.5605 +0.0743 -0.4302 -0.0123
#       -0.5300 +0.3072 +0.4294 -0.4270 +0.7855
#       -0.1486 -0.5312 -0.4648 +0.0439 -0.4705
#       +0.0544 +0.8661 +0.1420 +0.4978 +0.1713
#       +0.0123 +0.6019 +0.2353 -0.4628 -0.1064
#     
#     create-noise2d returns a Sub taking ($x, $y).
#     create-noise3d gives you a three-argument one.
