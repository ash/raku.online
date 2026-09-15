#!/usr/bin/env rakupp
# Noise::Simplex — Sampling a field
# https://raku.online/modules/noise-simplex/#sampling-a-field
#
# Install what it needs, then run it:
#     rakupp install Noise::Simplex
#     rakupp 02-reproducible.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Noise::Simplex;

say 'the same seed gives the same field, every time:';
my &a = Simplex.new(seed => 7).create-noise2d;
my &b = Simplex.new(seed => 7).create-noise2d;
say '  two objects, same seed  : ', so (^20).all.map({ a($_ * 0.3, 1.1) == b($_ * 0.3, 1.1) });
my &c = Simplex.new(seed => 8).create-noise2d;
say '  a different seed differs: ', a(0.25, 0.25) != c(0.25, 0.25);
say '';
say 'the range is [-1, 1]:';
my @vals = (^40 X ^40).map({ a(.[0] * 0.17, .[1] * 0.17) });
say '  min ', @vals.min.round(0.0001), '  max ', @vals.max.round(0.0001);
say '  all inside [-1, 1] : ', so @vals.all ~~ -1 .. 1;
say '  |mean| < 0.02      : ', @vals.sum.abs / @vals.elems < 0.02;
say '';
say 'the 2-D and 3-D fields are unrelated — n3(x, y, 0) is not n2(x, y):';
my &n3 = Simplex.new(seed => 7).create-noise3d;
say '  n2(0.25, 0.25)    = ', a(0.25, 0.25).round(0.000001);
say '  n3(0.25, 0.25, 0) = ', n3(0.25, 0.25, 0).round(0.000001);

# Output:
#     the same seed gives the same field, every time:
#       two objects, same seed  : True
#       a different seed differs: True
#     
#     the range is [-1, 1]:
#       min -0.9274  max 0.9139
#       all inside [-1, 1] : True
#       |mean| < 0.02      : True
#     
#     the 2-D and 3-D fields are unrelated — n3(x, y, 0) is not n2(x, y):
#       n2(0.25, 0.25)    = -0.193435
#       n3(0.25, 0.25, 0) = 0.743268
