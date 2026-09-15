---
name: Text::Caesar
version: 0.2
auth: zef:raku-community-modules
kind: Distribution · ciphers
summary: The rotate-by-N alphabet cipher, over the 26 uppercase ASCII letters
  only — and it is neither length-preserving nor invertible.
status: full
suite: 3 files, green
tested: 2026-09-15
license: NOASSERTION
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Text::Caesar
source: https://github.com/raku-community-modules/Text-Caesar.git
---

## What it is for

The Caesar cipher is the "hello world" of cryptography: rotate every letter
forward by a fixed key, rotate it back to read it. Nobody ships it to protect
anything; it earns its place in puzzles, teaching material and ROT-13 jokes.

This distribution gives you four subs — two on strings, two that read a file
and write another — plus three classes that wrap the same operation as
methods.

## Encrypting and decrypting

```raku name="basics"
use Text::Caesar;

say 'encrypt(3, "attack at dawn") = ', encrypt(3, 'attack at dawn');
say 'decrypt(3, that)            = ', decrypt(3, encrypt(3, 'attack at dawn'));
say '';
say 'rot13 is its own inverse:';
say '  ', encrypt(13, encrypt(13, 'HELLO'));
say '';
say 'only A..Z move; everything else passes straight through:';
say '  encrypt(5, "a-b,c 9") = ', encrypt(5, 'a-b,c 9');
```

```output
encrypt(3, "attack at dawn") = DWWDFN DW GDZQ
decrypt(3, that)            = ATTACK AT DAWN

rot13 is its own inverse:
  HELLO

only A..Z move; everything else passes straight through:
  encrypt(5, "a-b,c 9") = F-G,H 9
```

The key must be 1..25. Zero and 26 are rejected because they would be
no-ops, and the message is the same for both:

```raku name="keys"
use Text::Caesar;

for 0, 1, 25, 26, -3 -> $k {
    my $r = try encrypt($k, 'abc');
    say sprintf('key %3d -> %s', $k, $! ?? 'refused' !! $r);
}
```

```output
key   0 -> refused
key   1 -> BCD
key  25 -> ZAB
key  26 -> refused
key  -3 -> refused
```

## The case trap

`encrypt` upper-cases its argument first; `decrypt` does not. So the pair is
asymmetric, and lowercase ciphertext silently comes back unchanged:

```raku name="case"
use Text::Caesar;

my $cipher = encrypt(3, 'attack at dawn');
say 'ciphertext        : ', $cipher;
say 'decrypt(UPPER)    : ', decrypt(3, $cipher);
say 'decrypt(lowercase): ', decrypt(3, $cipher.lc);
say '';
say 'no error, no warning — the lowercase call is a no-op.';
```

```output
ciphertext        : DWWDFN DW GDZQ
decrypt(UPPER)    : ATTACK AT DAWN
decrypt(lowercase): dwwdfn dw gdzq

no error, no warning — the lowercase call is a no-op.
```

Anything that normalises ciphertext to lowercase before storing it gets its
ciphertext back instead of its plaintext.

## The one thing to know

A Caesar cipher is a permutation of the alphabet, so you expect it to be
length-preserving and invertible. This one is neither, because `.uc` is not a
one-to-one map in Unicode.

```raku name="lossy"
use Text::Caesar;

for 'Straße', 'ﬁle', 'wafﬄe' -> $plain {
    my $cipher = encrypt(1, $plain);
    my $back   = decrypt(1, $cipher);
    say sprintf('%-8s chars=%d  ->  %-10s chars=%d  ->  %-10s  round-trips? %s',
                $plain, $plain.chars, $cipher, $cipher.chars, $back,
                $back eq $plain.uc ?? 'to .uc' !! 'no');
}
say '';
say 'ß upper-cases to SS, so one character enciphers as two —';
say 'and there is no reverse mapping that puts it back.';
```

```output
Straße   chars=6  ->  TUSBTTF    chars=7  ->  STRASSE     round-trips? to .uc
ﬁle      chars=3  ->  GJMF       chars=4  ->  FILE        round-trips? to .uc
wafﬄe    chars=5  ->  XBGGGMF    chars=7  ->  WAFFFLE     round-trips? to .uc

ß upper-cases to SS, so one character enciphers as two —
and there is no reverse mapping that puts it back.
```

The round trip does not return your plaintext; at best it returns
`$plain.uc`, and for the expanding cases not even that.

## Where the two engines differ

Nothing in the four exported subs differs. One thing in the distribution's
own synopsis does: it writes `Message.new(...)` and `Secret.new(...)`, and
those short names are only visible under Raku++.

```raku name="qualified"
use Text::Caesar;

my $m = Text::Caesar::Message.new(key => 3, text => 'hi there');
say 'Message.encrypt : ', $m.encrypt;
my $s = Text::Caesar::Secret.new(key => 3, text => $m.encrypt);
say 'Secret.decrypt  : ', $s.decrypt;
say '';
say 'the classes are NOT exported — the fully qualified name is the';
say 'portable spelling. Rakudo rejects the short one at compile time.';
```

```output
Message.encrypt : KL WKHUH
Secret.decrypt  : HI THERE

the classes are NOT exported — the fully qualified name is the
portable spelling. Rakudo rejects the short one at compile time.
```

The three classes (`Caesar`, `Message`, `Secret`) live inside a `unit module`
and carry no `is export`. Raku++ leaks them into the importing scope under
their short names; Rakudo does not, and a program written against the short
spelling fails to compile there with `Undeclared name: Message`.

Two smaller notes on the file wrappers, which behave identically on both
engines. Each hop appends a newline, so a value that goes plaintext → file →
ciphertext → file grows by one byte per pass. And key validation is
inconsistent: `decrypt-from-file` carries a `where 1..25` on its signature
while the other three rely on the constructor dying, so the same mistake
raises two different exception types depending on which sub you called.
