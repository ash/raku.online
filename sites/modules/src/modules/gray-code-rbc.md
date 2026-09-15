---
name: Gray::Code::RBC
version: 0.0.4
auth: zef:thundergnat
kind: Distribution · encoding
summary: Convert between integers and reflected binary Gray code, where
  consecutive values differ by exactly one bit, at arbitrary precision.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:thundergnat/Gray::Code::RBC
source: git://github.com/thundergnat/Gray-Code-RBC.git
---

## What it is for

A rotary encoder that reads two bits at the moment they are both changing can
report a position that is neither the old one nor the new one. Gray code fixes
that by construction: consecutive values differ in exactly one bit, so a read
caught mid-transition can only ever be off by one.

The same property makes Gray code useful for hypercube traversal, Karnaugh
maps, and any enumeration where you want each step to be a single flip. This
distribution is the two conversions, at arbitrary precision.

## Encoding and decoding

```raku name="gray"
use Gray::Code::RBC;

for ^8 -> $n {
    my $g = gray-encode($n);
    printf "%d -> %s (%d) -> %d\n", $n, $g.base(2).fmt('%03s'), $g, gray-decode($g);
}
```

```output
0 -> 000 (0) -> 0
1 -> 001 (1) -> 1
2 -> 011 (3) -> 2
3 -> 010 (2) -> 3
4 -> 110 (6) -> 4
5 -> 111 (7) -> 5
6 -> 101 (5) -> 6
7 -> 100 (4) -> 7
```

That is the textbook RBC sequence 0, 1, 3, 2, 6, 7, 5, 4. The defining
property is worth asserting rather than eyeballing:

```raku name="hamming"
use Gray::Code::RBC;

my @codes = (^16).map({ gray-encode($_) });
my @distances = (^15).map({
    (@codes[$_] +^ @codes[$_ + 1]).base(2).comb.grep('1').elems
});
say 'hamming distances between consecutive codes : ', @distances.join(',');
say 'every one of them is 1                      : ', ?all(@distances.map(* == 1));
say 'round trip over 0..999                      : ',
    ?all((^1000).map({ gray-decode(gray-encode($_)) == $_ }));
```

```output
hamming distances between consecutive codes : 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
every one of them is 1                      : True
round trip over 0..999                      : True
```

## Arbitrary precision

```raku name="big"
use Gray::Code::RBC;

my $big = 2**100 + 12345;
say 'input      : ', $big;
say 'encoded    : ', gray-encode($big);
say 'round trip : ', gray-decode(gray-encode($big)) == $big;
say 'bit width  : ', gray-encode($big).base(2).chars;
```

```output
input      : 1267650600228229401496703217721
encoded    : 1901475900342344102245054818341
round trip : True
bit width  : 101
```

There is no fixed word size. A 101-bit integer encodes and round-trips
exactly, because the implementation is `$n +^ ($n +> 1)` over Raku's
arbitrary-precision integers rather than over a machine word.

## The one thing to know

Negative integers are accepted, and they silently produce a non-injective,
non-reversible encoding.

```raku name="negative-trap"
use Gray::Code::RBC;

for -4 .. 2 -> $n {
    my $g = gray-encode($n);
    say sprintf('gray-encode(%2d) = %d   round trip -> %2d   %s',
        $n, $g, gray-decode($g), gray-decode($g) == $n ?? 'ok' !! 'LOST');
}
say '';
say 'encode(-1) == encode(0) : ', gray-encode(-1) == gray-encode(0);
```

```output
gray-encode(-4) = 2   round trip ->  3   LOST
gray-encode(-3) = 3   round trip ->  2   LOST
gray-encode(-2) = 1   round trip ->  1   LOST
gray-encode(-1) = 0   round trip ->  0   LOST
gray-encode( 0) = 0   round trip ->  0   ok
gray-encode( 1) = 1   round trip ->  1   ok
gray-encode( 2) = 3   round trip ->  2   ok

encode(-1) == encode(0) : True
```

Gray coding is defined over non-negative integers only. The signature
constrains the argument to `Int|Str`, not to a non-negative value, so `-1` and
`0` both encode to 0 — two different inputs, one code — and every negative
input fails to round-trip. For an encoding whose entire purpose is a
one-to-one, one-bit-apart mapping, colliding codes with no error is the worst
possible failure.

Guard your own calls with `UInt` or `where * >= 0`.

## Where the two engines differ

Nowhere. Every spike in this page, including the negative-input collisions,
produced byte-identical output under Raku++ and Rakudo.

The `where Int|Str` constraint is worth a second look though, because it is
lenient in one direction and strict in the other. It **accepts** strings and
defers to `.Int`, so `gray-encode('0xff')` returns 128, the same as `'255'`,
because Raku's string-to-integer conversion understands the `0x` prefix. It
**rejects** `255e0`, `255.0` and `255/1` with a binding failure, even though
all three are integral — a `Num` that came out of arithmetic has to be
`.Int`ed by the caller. And a non-numeric string passes the `where` clause and
then dies later with `X::Str::Numeric` from the coercion, so the error points
at the conversion rather than at the signature.

There is no encoder for the binary-string form either: integers in, integers
out, and any `.base(2)` formatting is your job.
