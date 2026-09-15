---
name: Encoding::Huffman::PP6
version: 0.0.3
auth: zef:tony-o
kind: Distribution · encoding
summary: Bit-packed Huffman coding with the HPACK table built in — and a
  decoder that destroys every digit and every space.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: none stated
depends: none beyond the core
raku-land: https://raku.land/zef:tony-o/Encoding::Huffman::PP6
source: git://github.com/tony-o/perl6-encoding-huffman-pp6.git
---

## What it is for

Huffman coding assigns short bit patterns to common symbols. HTTP/2's HPACK
carries a fixed table for header text, and this distribution ships that table
along with an encoder and a decoder — or you can supply your own code table.

## Encoding

```raku name="basics"
use Encoding::Huffman::PP6;

for 'www.example.com', 'a', '', 'no-cache' -> $s {
    my $b = huffman-encode($s);
    say sprintf('  %-18s %2d bytes  %s', $s.raku, $b.bytes,
                $b.list.map({ .fmt('%02x') }).join);
}
say '';
say 'the encoder always terminates with the table`s 30-bit EOS symbol and';
say 'zero-pads to a byte boundary, so even the empty string is 4 bytes.';
```

```output
  "www.example.com"  15 bytes  f1e3c2e5f23a6ba0ab90f4fffffffe
  "a"                 5 bytes  1fffffffe0
  ""                  4 bytes  fffffffc
  "no-cache"         10 bytes  a8eb10649cbfffffff80

the encoder always terminates with the table`s 30-bit EOS symbol and
zero-pads to a byte boundary, so even the empty string is 4 bytes.
```

```raku name="custom"
use Encoding::Huffman::PP6;

my %codes = a => '0', b => '10', c => '110', _eos => '1110';
my $b = huffman-encode('abcabc', %codes);
say 'with a three-symbol table:';
say '  encoded : ', $b.list.map({ .fmt('%08b') }).join(' ');
say '  decoded : ', huffman-decode($b, %codes).raku;
say '';
say 'the table maps a single-character string to a string of binary';
say 'digits, and needs an _eos entry.';
```

```output
with a three-symbol table:
  encoded : 01011001 01101110 00000000
  decoded : "abcabc"

the table maps a single-character string to a string of binary
digits, and needs an _eos entry.
```

## The one thing to know

The decoder silently destroys every digit and every ASCII whitespace
character.

```raku name="digits"
use Encoding::Huffman::PP6;

for '0', '4', '9', ' ', 'a', 'HTTP 404 gone' -> $s {
    my $back = huffman-decode(huffman-encode($s));
    say sprintf('  %-16s -> %-24s %s', $s.raku, $back.raku,
                $back eq $s ?? 'OK' !! 'WRONG');
}
say '';
say 'the reverse lookup gives back a one-character Str, and the line';
say '  $r ~= try {%a{$a}.chr} // %a{$a}';
say 'calls .chr on it. Str.chr numifies first, so "4".chr is 4.chr — a';
say 'control character — and the `try` never fires because nothing failed.';
say '';
say 'encoding a header value, a date, a status code or anything with a';
say 'space through this module is lossy. Sixteen characters are affected:';
say '  tab, newline, VT, FF, CR, space, and the ten digits.';
```

```output
  "0"              -> "\0"                     WRONG
  "4"              -> "\x[4]"                  WRONG
  "9"              -> "\t"                     WRONG
  " "              -> "\0"                     WRONG
  "a"              -> "a"                      OK
  "HTTP 404 gone"  -> "HTTP\0\x[4]\0\x[4]\0gone" WRONG

the reverse lookup gives back a one-character Str, and the line
  $r ~= try {%a{$a}.chr} // %a{$a}
calls .chr on it. Str.chr numifies first, so "4".chr is 4.chr — a
control character — and the `try` never fires because nothing failed.

encoding a header value, a date, a status code or anything with a
space through this module is lossy. Sixteen characters are affected:
  tab, newline, VT, FF, CR, space, and the ten digits.
```

## Any byte sequence is "valid input"

```raku name="garbage"
use Encoding::Huffman::PP6;

for Buf[uint8].new(), Buf[uint8].new(0, 0, 0), Buf[uint8].new(0x12, 0x34, 0x56) -> $b {
    my $r = try huffman-decode($b);
    say sprintf('  %-28s -> %s', $b.list.map({ .fmt('%02x') }).join.raku,
                $! ?? 'threw' !! $r.raku);
}
say '';
say 'never an exception, never an undefined value — always a Str. There';
say 'is no checksum, no trailing-padding validation, and no way to tell a';
say 'corrupt buffer from a good one.';
say '';
say 'and encoding a character ABSENT from the table is silent too:';
my $euro = huffman-encode("\c[EURO SIGN]");
say '  huffman-encode("€") = ', $euro.list.map({ .fmt('%02x') }).join,
    '   <- the EOS alone';
```

```output
  ""                           -> ""
  "000000"                     -> "\0\0\0\0"
  "123456"                     -> "\x[2]sMp"

never an exception, never an undefined value — always a Str. There
is no checksum, no trailing-padding validation, and no way to tell a
corrupt buffer from a good one.

and encoding a character ABSENT from the table is silent too:
  huffman-encode("€") = fffffffc   <- the EOS alone
```

## It is not HPACK-compatible

```raku name="hpack"
use Encoding::Huffman::PP6;

say 'despite using the HPACK table, the OUTPUT is not HPACK:';
say '  HPACK pads with the EOS PREFIX to the next byte boundary;';
say '  this module emits the whole 30-bit EOS symbol.';
say '';
say '  huffman-encode("")                 : ', huffman-encode('').bytes, ' bytes (HPACK: 0)';
say '  huffman-encode("www.example.com")  : ',
    huffman-encode('www.example.com').bytes, ' bytes (HPACK: 12)';
say '';
say 'the DECODER is tolerant enough to read HPACK-style input:';
say '  huffman-decode(Buf[uint8].new(0x1f)) = ',
    huffman-decode(Buf[uint8].new(0x1f)).raku;
say '';
say 'so the asymmetry only bites on encode. Do not put this on a wire';
say 'that expects HPACK.';
```

```output
despite using the HPACK table, the OUTPUT is not HPACK:
  HPACK pads with the EOS PREFIX to the next byte boundary;
  this module emits the whole 30-bit EOS symbol.

  huffman-encode("")                 : 4 bytes (HPACK: 0)
  huffman-encode("www.example.com")  : 15 bytes (HPACK: 12)

the DECODER is tolerant enough to read HPACK-style input:
  huffman-decode(Buf[uint8].new(0x1f)) = "a"

so the asymmetry only bites on encode. Do not put this on a wire
that expects HPACK.
```

## Where the two engines differ

Two, and both concern which characters get destroyed. Raku++ does not enforce
the `Buf[uint8]` constraint, so a `Buf[uint16]` or a `Blob[uint8]` is accepted
and mis-decoded; and `Str.Numeric` rejects non-ASCII numerics there, so five
more characters — NEL, NBSP and the vulgar fractions — survive on Raku++ and
are destroyed on Rakudo.

```raku name="portable"
use Encoding::Huffman::PP6;

say 'the portable rule: only round-trip characters the decoder cannot';
say 'numify. Check before you rely on it:';
sub safe(Str $s) {
    huffman-decode(huffman-encode($s)) eq $s
}
for 'abcdef', 'a1b', 'no space', 'nospace' -> $s {
    say sprintf('  %-14s round-trips ? %s', $s.raku, safe($s));
}
say '';
say 'and always pass a real Buf[uint8] to the decoder:';
my Buf[uint8] $b = huffman-encode('abc');
say '  typed buffer decodes : ', huffman-decode($b).raku;
say '';
say 'one performance note: the reverse lookup table is rebuilt from';
say '%codes on EVERY huffman-decode call.';
```

```output
the portable rule: only round-trip characters the decoder cannot
numify. Check before you rely on it:
  "abcdef"       round-trips ? True
  "a1b"          round-trips ? False
  "no space"     round-trips ? False
  "nospace"      round-trips ? True

and always pass a real Buf[uint8] to the decoder:
  typed buffer decodes : "abc"

one performance note: the reverse lookup table is rebuilt from
%codes on EVERY huffman-decode call.
```
