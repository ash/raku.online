---
name: Digest
version: 1.1.0
auth: zef:grondilu
kind: Distribution · crypto
summary: MD5, SHA-1, SHA-2, SHA-3, RIPEMD-160 and HMAC written in Raku
  itself — one sub per algorithm, a Blob in and a Blob out, and no C to
  compile, at the speed that implies.
status: full
suite: 4 files, green
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/zef:grondilu/Digest
source: https://github.com/grondilu/libdigest-raku
---

## What it is for

Every hash function people still use, as Raku source: `md5`, `sha1`, the
four SHA-2 widths, the four SHA-3 widths with their two SHAKE cousins,
`rmd160`, and `hmac` to key any of them. Nothing is compiled at install time
and nothing is loaded from the operating system, so the distribution installs
anywhere Raku runs — a container with no compiler, a machine whose OpenSSL is
too old to bind — and the answer is the standard one to the last hex digit.

The price is that the arithmetic runs in the interpreter. For a password, a
cache key or an ETag that is nothing; for a gigabyte it is the wrong tool,
and the numbers further down say by how much.

## One sub per algorithm

```raku name="hashes"
use Digest::MD5;
use Digest::SHA2;
use Digest::SHA3;
use HMAC;

sub hex(Blob $b) { $b.list.fmt('%02x', '') }

say hex(md5('abc'));
say hex(sha256('abc'));
say hex(sha3_256('abc'));
say sha512('abc').elems;
say hex(hmac(key => 'key', msg => 'The quick brown fox jumps over the lazy dog',
             hash => &sha256, block-size => 64));
```

```output
900150983cd24fb0d6963f7d28e17f72
ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532
64
f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8
```

Each sub takes a `Blob` and returns one; hand it a `Str` and it is encoded as
UTF-8 first, which is what the examples do. There is no hex helper, hence the
three-line `hex` above — the digest is bytes, and turning it into a string is
your decision. `hmac` takes the hash as a sub reference and the algorithm's
block size, which is 64 for MD5, SHA-1 and SHA-256, and 128 for SHA-512.

SHAKE is the odd one out, because its output has no fixed length. The two
`shake` subs return a **lazy sequence of blocks** rather than one Blob: ask
for a byte count and you get the blocks that cover it, ask for `*` and the
stream never ends. Either way, `[~]` joins what you took:

```raku name="shake"
use Digest::SHA3;

sub hex(Blob $b) { $b.list.fmt('%02x', '') }

say hex([~] shake128('abc', 16));
say hex([~] shake128('abc', 40));
my @blocks = shake256('abc', *).head(2);
say @blocks.elems, ' blocks of ', @blocks[0].elems, ' bytes';
```

```output
5881092dd818bf5cf8a3ddb793fbcba7
5881092dd818bf5cf8a3ddb793fbcba74097d5c526a6d35f97b83351940f2cc844c50af32acd3f2c
2 blocks of 136 bytes
```

## Speed, measured

The same 64 KB of random bytes through each algorithm, one call, wall clock on
one machine:

| | Raku++ 3.28 | Rakudo 2026.08 |
|---|---|---|
| `md5` | 1.6 s | 1.3 s |
| `sha1` | 1.6 s | 3.1 s |
| `sha256` | 2.1 s | 3.9 s |
| `sha512` | 2.4 s | 2.7 s |
| `sha3_256` | 3.8 s | 9.8 s |

So a kilobyte costs tens of milliseconds and a megabyte costs half a minute:
`sha256` over 1 MB took 21 s here, where `Digest::SHA256::Native` — the same
digest through C — took 0.45 s. That is the trade the first paragraph
promised. Use this distribution where the input is small or the toolchain is
absent, and a native binding where the hashing is the work.

## The one thing to know

There is no `Digest` unit. `use Digest;` fails with *Could not find Digest*,
because the distribution named Digest provides `Digest::MD5`, `Digest::SHA1`,
`Digest::SHA2`, `Digest::SHA3`, `Digest::RIPEMD` and `HMAC` — six units, and
not one of them carries the distribution's own name. You import the algorithm
you want, and `sha256` lives in `Digest::SHA2` rather than in a unit called
after itself. The HMAC unit is likewise plain `HMAC`, with no `Digest::` in
front of it.
