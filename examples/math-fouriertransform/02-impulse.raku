#!/usr/bin/env rakupp
# Math::FourierTransform — Transforming
# https://raku.online/modules/math-fouriertransform/#transforming
#
# Install what it needs, then run it:
#     rakupp install Math::FourierTransform
#     rakupp 02-impulse.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::FourierTransform;

my Complex @delta = (1, 0, 0, 0).map(*.Complex);
say 'the impulse transforms to a flat spectrum:';
say '  ', discrete-fourier-transform(@delta).map({ .re.round(0.0001) }).join(', ');
say '';
my Complex @empty;
say 'an empty array is safe — the loop body never runs:';
say '  elems = ', discrete-fourier-transform(@empty).elems;
say '';
say 'the cost is N**2 transcendental calls — exp is invoked once per';
say '(k, n) pair, nothing is cached, and nothing here is an FFT.';

# Output:
#     the impulse transforms to a flat spectrum:
#       1, 1, 1, 1
#     
#     an empty array is safe — the loop body never runs:
#       elems = 0
#     
#     the cost is N**2 transcendental calls — exp is invoked once per
#     (k, n) pair, nothing is cached, and nothing here is an FFT.
