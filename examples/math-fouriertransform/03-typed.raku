#!/usr/bin/env rakupp
# Math::FourierTransform — The one thing to know
# https://raku.online/modules/math-fouriertransform/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::FourierTransform
#     rakupp 03-typed.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::FourierTransform;

say 'the shape that works everywhere:';
say '  my Complex @x = (1, 2, 3, 4).map(*.Complex);';
my Complex @x = (1, 2, 3, 4).map(*.Complex);
say '  -> ', discrete-fourier-transform(@x).elems, ' components';
say '';
say 'the shapes Rakudo refuses:';
say '  my @a = 1, 2, 3, 4;                 # untyped, holding Ints';
say '  my @a = (1+0i, 2+0i);               # untyped, holding Complex';
say '  discrete-fourier-transform((1+0i, 2+0i));   # a bare list';
say '';
say 'all three raise "expected Positional[Complex]" there. Raku++ does';
say 'not check the element type at all and quietly transforms whatever';
say 'you gave it — including an array declared `my Num @nums`, which';
say 'Rakudo rejects at COMPILE time.';
say '';
say 'so declare the array, and coerce into it:';
sub dft(*@values) {
    my Complex @c = @values.map(*.Complex);
    discrete-fourier-transform(@c)
}
say '  dft(1, 2, 3, 4) : ', dft(1, 2, 3, 4).map({ .re.round(0.0001) }).join(', ');

# Output:
#     the shape that works everywhere:
#       my Complex @x = (1, 2, 3, 4).map(*.Complex);
#       -> 4 components
#     
#     the shapes Rakudo refuses:
#       my @a = 1, 2, 3, 4;                 # untyped, holding Ints
#       my @a = (1+0i, 2+0i);               # untyped, holding Complex
#       discrete-fourier-transform((1+0i, 2+0i));   # a bare list
#     
#     all three raise "expected Positional[Complex]" there. Raku++ does
#     not check the element type at all and quietly transforms whatever
#     you gave it — including an array declared `my Num @nums`, which
#     Rakudo rejects at COMPILE time.
#     
#     so declare the array, and coerce into it:
#       dft(1, 2, 3, 4) : 10, -2, -2, -2
