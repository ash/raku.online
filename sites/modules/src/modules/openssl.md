---
name: OpenSSL
version: 0.2.9
auth: zef:raku-community-modules
kind: Distribution · crypto
summary: The OpenSSL library through NativeCall — digests, symmetric
  ciphers, RSA, X.509 and the TLS socket that IO::Socket::SSL is built on —
  in nineteen units, of which most programs want two.
status: full
suite: 8 files, green
tested: 2026-09-14
license: MIT
raku-land: https://raku.land/zef:raku-community-modules/OpenSSL
source: https://github.com/raku-community-modules/OpenSSL
---

## What it is for

Everything cryptographic that the operating system already ships in
`libcrypto` and `libssl`, reached from Raku without reimplementing any of
it: a SHA-256 that runs at C speed, AES with a real key schedule, RSA keys
that other tools can read, certificates, and the TLS handshake that every
HTTPS client needs. Seventeen distributions depend on it, and the one most
people meet first is `IO::Socket::SSL`, which is a thin layer over the
`OpenSSL` unit here.

Nineteen units is a lot, and the split is by what you are doing rather than
by what OpenSSL calls it. `OpenSSL::Digest` and `OpenSSL::CryptTools` are
the two for ordinary programs; `OpenSSL::RSATools` signs and verifies;
`OpenSSL::X509` reads certificates; the rest are the socket and the raw
bindings behind them.

## A digest and a cipher

```raku name="digest-and-cipher"
use OpenSSL::Digest;
use OpenSSL::CryptTools;

say sha256-hex('abc');
say md5-hex('abc');
say sha1('abc').elems, ' ', sha512('abc').elems;

my $key = Buf.new(^32);
my $iv  = Buf.new(^16);
my $secret = 'attack at dawn'.encode;
my $sealed = encrypt($secret, :aes256, :$key, :$iv);
say $sealed.elems, ' bytes; starts like the plaintext: ', $sealed.subbuf(0, 4) eqv $secret.subbuf(0, 4);
say decrypt($sealed, :aes256, :$key, :$iv).decode;
say decrypt($sealed, :aes256, key => Buf.new((^32).map(* + 1)), :$iv).elems;
```

```output
ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
900150983cd24fb0d6963f7d28e17f72
20 64
16 bytes; starts like the plaintext: False
attack at dawn
0
```

Each digest comes in two spellings — `sha256` returns the bytes, `sha256-hex`
the string — and takes a `Str` (encoded as UTF-8) or a `Blob`. Fourteen
bytes of plaintext become sixteen of ciphertext because AES works in blocks
and pads the last one, and the same key and IV get the text back.

## The one thing to know

A wrong key does not throw. The last line above decrypts with a key that is
off by one in every byte and gets **zero bytes** back — the padding check
fails inside OpenSSL, the binding reports that as an empty buffer, and no
exception marks the spot. Code that treats an empty result as "the message
was empty" has a silent hole in it; check `.elems` before trusting a
decryption, or better, authenticate the ciphertext (an HMAC over it, keyed
separately) and refuse to decrypt anything that fails the check.

The key and IV lengths are the other thing the binding will not check for
you: `:aes256` wants exactly 32 key bytes and a 16-byte IV, `:aes128` 16
and 16. Short buffers are read past their end by the C code, which is the
kind of bug that works on one machine and not another.
