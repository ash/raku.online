---
name: TinyFloats
version: 0.0.5
auth: zef:japhb
kind: Distribution · numeric
summary: Convert between Raku Nums and the bit patterns of four small
  floating-point formats — binary16, bfloat16, TensorFloat-32 and E5M2.
status: divergent
suite: 5 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:japhb/TinyFloats
source: https://github.com/japhb/TinyFloats.git
---

## What it is for

Graphics and machine learning both ran out of memory bandwidth before they ran
out of precision, so both moved to smaller floats. Half precision is the GPU
texture format; bfloat16 keeps a float32's exponent range in sixteen bits and
is what most training hardware uses; TensorFloat-32 is NVIDIA's nineteen-bit
compromise; E5M2 is eight bits total.

Reading or writing any of those from Raku means converting to and from the bit
patterns, which is what this distribution does.

## Converting

```raku name="convert"
use TinyFloats;

for 0e0, 1e0, -1e0, 0.5e0, 3.14e0, 65504e0, Inf, -Inf -> $n {
    my $bits = bin16-from-num($n);
    say sprintf('%-10s bits=0x%04X  back=%s', $n.gist, $bits, num-from-bin16($bits).gist);
}
say '';
my $nan = bin16-from-num(NaN);
say sprintf('NaN        bits=0x%04X  back=%s (isNaN=%s)',
    $nan, num-from-bin16($nan).gist, num-from-bin16($nan).isNaN);
```

```output
0          bits=0x0000  back=0
1          bits=0x3C00  back=1
-1         bits=0xBC00  back=-1
0.5        bits=0x3800  back=0.5
3.14       bits=0x4247  back=3.138671875
65504      bits=0x7BFF  back=65504
Inf        bits=0x7C00  back=Inf
-Inf       bits=0xFC00  back=-Inf

NaN        bits=0x7E00  back=NaN (isNaN=True)
```

Zero, one, a half, infinity and NaN all survive exactly. `3.14` does not, and
should not — that is what sixteen bits buys you.

## The four formats side by side

```raku name="formats"
use TinyFloats;

for 1e0, 0.1e0 -> $n {
    say sprintf('%-6s bin16=0x%04X  bf16=0x%04X  e5m2=0x%02X  tf32=0x%08X',
        $n.gist, bin16-from-num($n), bf16-from-num($n), e5m2-from-num($n), tf32-from-num($n));
    say sprintf('       back: bin16=%-22s bf16=%-16s e5m2=%-10s tf32=%s',
        num-from-bin16(bin16-from-num($n)).gist,
        num-from-bf16(bf16-from-num($n)).gist,
        num-from-e5m2(e5m2-from-num($n)).gist,
        num-from-tf32(tf32-from-num($n)).gist);
}
```

```output
1      bin16=0x3C00  bf16=0x3F80  e5m2=0x3C  tf32=0x0001FC00
       back: bin16=1                      bf16=1                e5m2=1          tf32=1
0.1    bin16=0x2E66  bf16=0x3DCC  e5m2=0x2E  tf32=0x0001EE66
       back: bin16=0.0999755859375        bf16=0.099609375      e5m2=0.09375    tf32=0.0999755859375
```

`0.1` shows the precision ladder clearly: bfloat16 is the coarsest of the
sixteen-bit pair because it spends its bits on exponent range, and E5M2 at
eight bits gets nowhere near.

## Boundaries

```raku name="boundaries"
use TinyFloats;

say 'bin16 maximum finite value 65504 : 0x', bin16-from-num(65504e0).base(16);
say 'bin16 of 70000 overflows to Inf  : ', num-from-bin16(bin16-from-num(70000e0)).gist;
say 'bin16 of 1e-8 underflows to zero : ', num-from-bin16(bin16-from-num(1e-8)).gist;
say '';
say 'e5m2 maximum finite value 57344  : ', num-from-e5m2(e5m2-from-num(57344e0)).gist;
say 'e5m2 of 1e6 overflows to Inf     : ', num-from-e5m2(e5m2-from-num(1e6)).gist;
say '';
say 'negative zero keeps its sign bit : 0x', bin16-from-num(-0e0).base(16);
```

```output
bin16 maximum finite value 65504 : 0x7BFF
bin16 of 70000 overflows to Inf  : Inf
bin16 of 1e-8 underflows to zero : 0

e5m2 maximum finite value 57344  : 57344
e5m2 of 1e6 overflows to Inf     : Inf

negative zero keeps its sign bit : 0x8000
```

Overflow saturates to infinity and underflow flushes to zero, which is what
IEEE says should happen.

## The one thing to know

The `*-from-num` subs take an untyped `$num` and require a real native `Num`,
and the two engines disagree about what happens if you hand them anything
else.

`bin16-from-num(1)` — an `Int` literal, which is what `1` is in Raku — returns
the perfectly correct `15360` on Raku++ and **throws** `This type cannot unbox
to a native number: P6opaque, Int` on Rakudo. Same for a `Rat`, so
`bin16-from-num(0.5)` is Raku++-only too.

Because the signature is untyped there is no compile-time warning on either
engine, and numeric literals in Raku are `Int` and `Rat` by default — so
`bin16-from-num(1)` and `bin16-from-num(0.5)` are the *natural* things to
write and neither is portable.

Write `1e0` and `0.5e0`, or coerce with `.Num`, as every example on this page
does.

## Where the two engines differ

That input-type divergence is the difference, and it is the one that matters.
Once the argument is a genuine `Num`, every conversion in this page is
byte-identical on both engines.

One thing to guard on both: `num-from-bin16` performs **no range check on its
input**. A negative value and a pattern wider than sixteen bits both silently
return `NaN`, so a corrupted or mis-shifted bit pattern is indistinguishable
from a genuine NaN payload:

```raku name="range"
use TinyFloats;

say 'num-from-bin16(-1)      : ', num-from-bin16(-1).gist;
say 'num-from-bin16(0x1FFFF) : ', num-from-bin16(0x1FFFF).gist, '   (17 bits wide)';
say 'a genuine NaN pattern   : ', num-from-bin16(0x7E00).gist;
say '';
say 'all three are indistinguishable by their result';
```

```output
num-from-bin16(-1)      : NaN
num-from-bin16(0x1FFFF) : NaN   (17 bits wide)
a genuine NaN pattern   : NaN

all three are indistinguishable by their result
```

Mask your input to the format's width before decoding.
