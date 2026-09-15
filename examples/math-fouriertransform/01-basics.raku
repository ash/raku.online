#!/usr/bin/env rakupp
# Math::FourierTransform — Transforming
# https://raku.online/modules/math-fouriertransform/#transforming
#
# Install what it needs, then run it:
#     rakupp install Math::FourierTransform
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::FourierTransform;

my Complex @x = (1, 2, 3, 4).map(*.Complex);
my @X = discrete-fourier-transform(@x);
say 'input  : ', @x.map(*.re.Int).join(', ');
say 'output :';
for @X.kv -> $k, $v {
    say sprintf('  X[%d] = %8.4f %+8.4fi', $k, $v.re, $v.im);
}
say '';
say '10, -2+2i, -2, -2-2i is the published result for the forward';
say 'unnormalised DFT of (1,2,3,4), which pins the sign convention and';
say 'the absence of a 1/N factor.';

# Output:
#     input  : 1, 2, 3, 4
#     output :
#       X[0] =  10.0000  +0.0000i
#       X[1] =  -2.0000  +2.0000i
#       X[2] =  -2.0000  -0.0000i
#       X[3] =  -2.0000  -2.0000i
#     
#     10, -2+2i, -2, -2-2i is the published result for the forward
#     unnormalised DFT of (1,2,3,4), which pins the sign convention and
#     the absence of a 1/N factor.
