---
name: Math::FourierTransform
version: 0.0.1
auth: github:MattOates
kind: Distribution · numbers
summary: A naive O(N²) discrete Fourier transform over `Complex` — exact
  conventions, and a signature that demands a typed array.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:MattOates/Math::FourierTransform
source: git://github.com/MattOates/Math--FourierTransform.git
---

## What it is for

The DFT turns a sampled signal into its frequency components. This
distribution implements the textbook double sum directly: `e^{-2πikn/N}`, no
1/N scaling, no decimation, no caching — one exported sub and nothing else.

## Transforming

```raku name="basics"
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
```

```output
input  : 1, 2, 3, 4
output :
  X[0] =  10.0000  +0.0000i
  X[1] =  -2.0000  +2.0000i
  X[2] =  -2.0000  -0.0000i
  X[3] =  -2.0000  -2.0000i

10, -2+2i, -2, -2-2i is the published result for the forward
unnormalised DFT of (1,2,3,4), which pins the sign convention and
the absence of a 1/N factor.
```

```raku name="impulse"
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
```

```output
the impulse transforms to a flat spectrum:
  1, 1, 1, 1

an empty array is safe — the loop body never runs:
  elems = 0

the cost is N**2 transcendental calls — exp is invoked once per
(k, n) pair, nothing is cached, and nothing here is an FFT.
```

## The one thing to know

`Complex @input` constrains the array's **declared element type**, not what it
happens to hold. An ordinary array full of `Complex` values is not enough.

```raku name="typed"
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
```

```output
the shape that works everywhere:
  my Complex @x = (1, 2, 3, 4).map(*.Complex);
  -> 4 components

the shapes Rakudo refuses:
  my @a = 1, 2, 3, 4;                 # untyped, holding Ints
  my @a = (1+0i, 2+0i);               # untyped, holding Complex
  discrete-fourier-transform((1+0i, 2+0i));   # a bare list

all three raise "expected Positional[Complex]" there. Raku++ does
not check the element type at all and quietly transforms whatever
you gave it — including an array declared `my Num @nums`, which
Rakudo rejects at COMPILE time.

so declare the array, and coerce into it:
  dft(1, 2, 3, 4) : 10, -2, -2, -2
```

## Where the two engines differ

Exactly that missing element-type enforcement, and this module is the purest
test case for it, because its whole signature is that one constraint. Code
written on Raku++ against an untyped array does not compile on Rakudo.

```raku name="portable"
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
```

```output
round trip : 1, 2, 3, 4
recovered  : True

one thing to keep out of any example: .raku of the result renders as
$[…] on Raku++ and Array[Complex].new(…) on Rakudo. Print the
components, not the container.
```
