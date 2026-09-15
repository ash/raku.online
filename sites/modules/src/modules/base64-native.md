---
name: Base64::Native
version: 0.0.10
auth: zef:dwarring
kind: Distribution · encoding
summary: Base64 over a bundled C codec, doing the whole buffer in one call and
  working in Blobs throughout, with the URL-safe alphabet as a flag.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none at runtime
raku-land: https://raku.land/zef:dwarring/Base64::Native
source: https://github.com/pdf-raku/Base64-Native-raku.git
---

## What it is for

Base64 shows up wherever binary has to travel through a text channel: data
URIs, JSON payloads, mail attachments, JWT segments. A pure-Raku codec is fine
until the buffer is a megabyte, at which point the per-byte loop is the whole
cost.

This distribution hands the buffer to a bundled C implementation in one call.

## Encoding and decoding

```raku name="b64"
use Base64::Native;

say 'encode returns a buffer : ', base64-encode('Hello, Raku!').decode;
say 'with :str, a Str        : ', base64-encode('Hello, Raku!', :str).raku;
say 'decode gives bytes back : ',
    base64-decode(base64-encode('Hello, Raku!', :str)).decode.raku;
say '';
say 'padding:';
for '', 'a', 'ab', 'abc', 'abcd' -> $s {
    say sprintf('  %-6s (%d bytes) -> %s', $s.raku, $s.chars, base64-encode($s, :str).raku);
}
```

```output
encode returns a buffer : SGVsbG8sIFJha3Uh
with :str, a Str        : "SGVsbG8sIFJha3Uh"
decode gives bytes back : "Hello, Raku!"

padding:
  ""     (0 bytes) -> ""
  "a"    (1 bytes) -> "YQ=="
  "ab"   (2 bytes) -> "YWI="
  "abc"  (3 bytes) -> "YWJj"
  "abcd" (4 bytes) -> "YWJjZA=="
```

`base64-encode` returns a `Buf`, so `say base64-encode('hi')` prints a hex
gist. Ask for `:str`, or `.decode` the result.

## Binary

```raku name="binary"
use Base64::Native;

my $blob = Blob.new(0, 1, 2, 250, 251, 255);
my $enc  = base64-encode($blob, :str);
say 'bytes   : ', $blob.list.join(' ');
say 'encoded : ', $enc.raku;
say 'decoded : ', base64-decode($enc).list.join(' ');
say 'exact   : ', base64-decode($enc).list eqv $blob.list;
```

```output
bytes   : 0 1 2 250 251 255
encoded : "AAEC+vv/"
decoded : 0 1 2 250 251 255
exact   : True
```

## The URL-safe alphabet

```raku name="uri"
use Base64::Native;

my $plus  = Blob.new(0xFB, 0xEF, 0xBE);
my $slash = Blob.new(0xFF, 0xFF, 0xFF);

say 'standard : ', base64-encode($plus, :str), '  ', base64-encode($slash, :str);
say 'uri      : ', base64-encode($plus, buf8.allocate(4), :uri).decode,
    '  ', base64-encode($slash, buf8.allocate(4), :uri).decode;
say '';
say 'note the padding is kept in both:';
say '  standard "a" : ', base64-encode('a', :str).raku;
```

```output
standard : ++++  ////
uri      : ----  ____

note the padding is kept in both:
  standard "a" : "YQ=="
```

`:uri` swaps `+` for `-` and `/` for `_` and **keeps the `=` padding**, so the
output is not a drop-in URL token — strip the padding yourself if the
consumer expects the unpadded form. `base64-decode` accepts either alphabet
without being told which.

## The one thing to know

The optional second positional is your **output buffer**, and if it is the
wrong size the encoder neither errors nor trims.

```raku name="buffer-trap"
use Base64::Native;

my $in = 'Hello, Raku!';           # 12 bytes -> 16 base64 characters

say 'default buffer : ', base64-encode($in, :str).raku;
say 'buffer of 8    : ', base64-encode($in.encode, buf8.allocate(8)).decode.raku;
say 'buffer of 4    : ', base64-encode($in.encode, buf8.allocate(4)).decode.raku;
say 'buffer of 64   : ', base64-encode($in.encode, buf8.allocate(64)).decode.raku;
```

```output
default buffer : "SGVsbG8sIFJha3Uh"
buffer of 8    : "SGVsbG8s"
buffer of 4    : "SGVs"
buffer of 64   : "SGVsbG8sIFJha3Uh\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
```

A short buffer silently produces half the base64 and no error — and
`"SGVsbG8s"` is a perfectly valid, perfectly wrong encoding of the first eight
bytes. A long buffer comes back with its trailing NULs still in it.

`base64-decode` is not symmetric here: it calls `.reallocate` and trims. So
anyone reusing a scratch buffer across calls of varying length corrupts their
data in one direction only, without a single diagnostic. Let the encoder
allocate unless you have measured that it matters.

## Where the two engines differ

On what reaches the C decoder when the input is not Latin-1.

`base64-decode(Str)` encodes the string as Latin-1 first. Rakudo refuses a
codepoint above 255 outright — `Error encoding Latin-1 string: could not
encode codepoint 8364` — while Raku++ substitutes `?` (0x3F), so the decoder
reports `stopped at byte 3: 0x3F "?"` and blames the wrong thing. Either way
the call fails; only Rakudo tells you why.

Two things that are the same on both. **Truncated groups are accepted**:
`base64-decode('Y')` returns a byte manufactured from six bits rather than
complaining, and only genuinely out-of-alphabet characters are rejected. And
`:str` is declared `where .so`, so `:str(False)` is not "no" — it fails to
dispatch entirely, with `no matching multi candidate`. Pass `:str` or omit it,
never a runtime boolean.

MIME-wrapped input, with newlines every 76 characters, decodes correctly on
both engines, and `=` padding is optional on decode.
