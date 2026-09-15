#!/usr/bin/env rakupp
# Noise::Simplex — The seed is taken modulo 2^64
# https://raku.online/modules/noise-simplex/#the-seed-is-taken-modulo-264
#
# Install what it needs, then run it:
#     rakupp install Noise::Simplex
#     rakupp 04-seed.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Noise::Simplex;

sub fingerprint($seed) {
    my &n = Simplex.new(:$seed).create-noise2d;
    (^12).map({ n($_ * 0.37, 1.13).round(0.000001) }).join(',')
}
say 'congruent Int seeds give the identical field:';
say '  5 and 5 + 2**64     : ', fingerprint(5) eq fingerprint(5 + 2**64);
say '  -1 and 2**64 - 1    : ', fingerprint(-1) eq fingerprint(2**64 - 1);
say '  0 and 2**128        : ', fingerprint(0) eq fingerprint(2**128);
say '  -1 and 2**63 - 1    : ', fingerprint(-1) eq fingerprint(2**63 - 1);
say '';
say 'seed is required — Simplex.new with none refuses:';
my $r = try Simplex.new;
say '  Simplex.new -> ', $! ?? 'refused' !! 'built';

# Output:
#     congruent Int seeds give the identical field:
#       5 and 5 + 2**64     : True
#       -1 and 2**64 - 1    : True
#       0 and 2**128        : True
#       -1 and 2**63 - 1    : False
#     
#     seed is required — Simplex.new with none refuses:
#       Simplex.new -> refused
