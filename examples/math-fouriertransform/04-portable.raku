#!/usr/bin/env rakupp
# Math::FourierTransform — Where the two engines differ
# https://raku.online/modules/math-fouriertransform/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Math::FourierTransform
#     rakupp 04-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::FourierTransform;

# round trip through a hand-written inverse, to show the convention
sub idft(@X) {
    my $N = @X.elems;
    (^$N).map(-> $n {
        ([+] (^$N).map(-> $k { @X[$k] * exp(2i * pi * $k * $n / $N) })) / $N
    })
}

my Complex @x = (1, 2, 3, 4).map(*.Complex);
my @back = idft(discrete-fourier-transform(@x));
say 'round trip : ', @back.map({ .re.round(0.0001) }).join(', ');
say 'recovered  : ', so (@back Z @x).all.map({ abs(.[0] - .[1]) < 1e-9 });
say '';
say 'one thing to keep out of any example: .raku of the result renders as';
say '$[…] on Raku++ and Array[Complex].new(…) on Rakudo. Print the';
say 'components, not the container.';

# Output:
#     round trip : 1, 2, 3, 4
#     recovered  : True
#     
#     one thing to keep out of any example: .raku of the result renders as
#     $[…] on Raku++ and Array[Complex].new(…) on Rakudo. Print the
#     components, not the container.
