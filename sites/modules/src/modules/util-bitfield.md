---
name: Util::Bitfield
version: 0.1.0
auth: zef:jonathanstowe
kind: Distribution · bit manipulation
summary: Pick apart the sub-byte fields of a packed binary word — extract,
  insert and mask — with bit positions counted from the most significant end,
  as protocol diagrams draw them.
status: partial
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:jonathanstowe/Util::Bitfield
source: git://github.com/jonathanstowe/Util-Bitfield.git
---

## What it is for

Network headers, hardware registers and binary file formats pack several
fields into one word, and the specification draws them left to right with bit
0 at the most significant end. Translating that diagram into shifts and masks
is exactly the kind of arithmetic that is easy to get subtly wrong and hard to
spot afterwards.

This distribution does the arithmetic in the specification's own terms: name
the field by its width, its start bit and the containing word size.

## Extracting a field

```raku name="extract"
use Util::Bitfield;

my $word = 0b1010_1100_0011_0101_1111_0000_1001_0110;
say 'word = ', $word.base(2), ' (0x', $word.base(16), ')';
say '';

for (4, 0), (4, 4), (8, 0), (8, 8), (8, 24), (16, 0), (16, 16) -> ($bits, $start) {
    my $x = extract-bits($word, $bits, $start);
    say sprintf('extract-bits(word, bits=%-2d, start=%-2d) = %-6d 0b%s',
        $bits, $start, $x, $x.base(2));
}
```

```output
word = 10101100001101011111000010010110 (0xAC35F096)

extract-bits(word, bits=4 , start=0 ) = 10     0b1010
extract-bits(word, bits=4 , start=4 ) = 12     0b1100
extract-bits(word, bits=8 , start=0 ) = 172    0b10101100
extract-bits(word, bits=8 , start=8 ) = 53     0b110101
extract-bits(word, bits=8 , start=24) = 150    0b10010110
extract-bits(word, bits=16, start=0 ) = 44085  0b1010110000110101
extract-bits(word, bits=16, start=16) = 61590  0b1111000010010110
```

Bit 0 is the **most significant** bit, so `extract-bits($v, 8, 0)` is the top
byte and `extract-bits($v, 8, 24)` the bottom one. Everything is relative to
`$word-size`, which defaults to 32 — so a small number has its bits at the far
end, and `extract-bits(5, 4, 0)` is 0 for every word size.

## Masks and insertion

```raku name="mask"
use Util::Bitfield;

sub b($v, $w = 32) { sprintf('%0*b', $w, $v) }

for (4, 0), (4, 4), (8, 8), (1, 31) -> ($bits, $start) {
    say sprintf('make-mask(bits=%-2d start=%-2d) = %s  (0x%08X)',
        $bits, $start, b(make-mask($bits, $start)), make-mask($bits, $start));
}
say 'make-mask(4, 0, :invert)     = ', b(make-mask(4, 0, :invert));
say 'make-mask(8, 0, 16)          = ', b(make-mask(8, 0, 16), 16), '  (word-size 16)';
say '';
my $word = 0b1010_1100_0011_0101_1111_0000_1001_0110;
my $new = insert-bits(0b101, $word, 3, 8);
say 'insert 0b101 at start=8 width=3:';
say '  before : ', b($word);
say '  after  : ', b($new);
say '  reads back as : ', extract-bits($new, 3, 8).base(2);
```

```output
make-mask(bits=4  start=0 ) = 11110000000000000000000000000000  (0xF0000000)
make-mask(bits=4  start=4 ) = 00001111000000000000000000000000  (0x0F000000)
make-mask(bits=8  start=8 ) = 00000000111111110000000000000000  (0x00FF0000)
make-mask(bits=1  start=31) = 00000000000000000000000000000001  (0x00000001)
make-mask(4, 0, :invert)     = 00001111111111111111111111111111
make-mask(8, 0, 16)          = 1111111100000000  (word-size 16)

insert 0b101 at start=8 width=3:
  before : 10101100001101011111000010010110
  after  : 10101100101101011111000010010110
  reads back as : 101
```

`insert-bits` guards against overflow properly, with a typed
`Util::Bitfield::X::BitOverflow` when the value is wider than the field.

## Splitting a value into bits

```raku name="split"
use Util::Bitfield;

say 'split-bits(8, 255)    : ', split-bits(8, 255).List.raku;
say 'split-bits(8, 0b1010) : ', split-bits(8, 0b1010).List.raku;
say 'split-bits(16, 0xAC35): ', split-bits(16, 0xAC35).List.raku;
say '';
say 'the value must fit in the width:';
say '  split-bits(8, 256) -> ', (try split-bits(8, 256)).defined ?? 'accepted' !! 'refused';
```

```output
split-bits(8, 255)    : (1, 1, 1, 1, 1, 1, 1, 1)
split-bits(8, 0b1010) : (0, 0, 0, 0, 1, 0, 1, 0)
split-bits(16, 0xAC35): (1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1)

the value must fit in the width:
  split-bits(8, 256) -> refused
```

Most significant bit first, matching the rest of the module.

## The one thing to know

`extract-bits-list` ignores the width you ask for. It always extracts **six-bit
fields**; `$bits` controls only how many values come back.

```raku name="list-trap"
use Util::Bitfield;

my $word = 0xAC35F096;

say 'extract-bits-list(word, 4) asks for 4-bit fields:';
my @l = extract-bits-list($word, 4).List;
say '  ', @l.raku;
say '  largest value : ', @l.max, '   but a 4-bit field holds 0..15';
say '  values over 15: ', @l.grep(* > 15).List.raku;
say '';
say 'every result is really a SIX-bit field, whatever you ask for:';
for 4, 8, 16 -> $bits {
    my $n = 32 div $bits;
    my @pred = (^$n).map({ ($word +> (32 - $_ * $bits - 6)) +& 0b111111 });
    my @got  = extract-bits-list($word, $bits).List;
    say sprintf('  bits=%-2d  got=%-30s  six-bit prediction matches: %s',
        $bits, @got.raku, @got eqv @pred);
}
say '';
say 'the honest answer, from extract-bits itself:';
for 4, 8, 16 -> $bits {
    my $n = 32 div $bits;
    say sprintf('  bits=%-2d  %s', $bits,
        (^$n).map({ extract-bits($word, $bits, $_ * $bits, 32) }).List.raku);
}
```

```output
extract-bits-list(word, 4) asks for 4-bit fields:
  [43, 48, 13, 23, 60, 2, 37, 24]
  largest value : 60   but a 4-bit field holds 0..15
  values over 15: (43, 48, 23, 60, 37, 24)

every result is really a SIX-bit field, whatever you ask for:
  bits=4   got=[43, 48, 13, 23, 60, 2, 37, 24]  six-bit prediction matches: True
  bits=8   got=[43, 13, 60, 37]                six-bit prediction matches: True
  bits=16  got=[43, 60]                        six-bit prediction matches: True

the honest answer, from extract-bits itself:
  bits=4   (10, 12, 3, 5, 15, 0, 9, 6)
  bits=8   (172, 53, 240, 150)
  bits=16  (44085, 61590)
```

Two independent proofs: the values **exceed the requested field width** — 60
does not fit in four bits — and every result matches the closed form
`($word +> (word-size − start − 6)) +& 0b111111` exactly, for three different
widths.

In plain terms, `extract-bits-list(0x01020304, 8)` returns `(0, 0, 0, 1)` where
the bytes are obviously `(1, 2, 3, 4)`. The routine silently disagrees with
`extract-bits`, the very sub it is meant to be a convenience wrapper for.

Build the loop by hand.

## Where the two engines differ

Nowhere. Every mask, every extraction, every insertion, the overflow guard and
the six-bit defect behaved identically on Raku++ and Rakudo.

Two things to guard at your own call site, since the module does not.
**Negative numbers slip through every check**: `make-mask(-1, 0)` returns a
nonsense negative mask and `insert-bits(-1, 0, 4, 0)` produces garbage with no
overflow complaint, while `extract-bits(-1, 4, 0)` quietly gives 15. And there
is **no bounds check against the word size**: `extract-bits($word, 8, 28)`
runs past the end of a 32-bit word and `extract-bits($word, 40, 0)` asks for a
field wider than the word, both without a word of complaint.
