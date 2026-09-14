---
name: Digest::SHA256::Native
version: 1.0.2
auth: zef:bduggan
kind: Distribution · crypto
summary: SHA-256 through a C implementation rather than a Raku one — two subs,
  one returning the raw digest and one the hex string, for when hashing is on a
  path that runs often enough for the speed to show.
status: full
suite: 9 files, green
tested: 2026-09-14
license: Artistic-2.0
depends: LibraryMake
raku-land: https://raku.land/zef:bduggan/Digest::SHA256::Native
source: https://github.com/bduggan/raku-digest-sha256-native
---

## What it is for

SHA-256 is the hash you reach for when you want a content address: a cache key
that changes when the content does, an ETag, a fingerprint proving two files
are the same, the leaves of a Merkle tree. Pure-Raku implementations exist and
are correct, but a hash is usually in a loop — every file in a tree, every
chunk of an upload — and that is where the cost of doing thirty-two-bit
arithmetic in an interpreter shows up.

This distribution binds the C implementation through NativeCall. The
distribution builds the shared library at install time, which is why
`LibraryMake` is a dependency and why installing it needs a working C
compiler; after that it is two subs.

## Both subs

```raku name="hash"
use Digest::SHA256::Native;

say sha256-hex('hello');
say sha256-hex('');
say sha256-hex('hello').chars;
```

```output
2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
64
```

Those are the canonical answers — the second is the SHA-256 of the empty
string, the value worth memorising because it is what you get when a file you
meant to read came back empty. `sha256-hex` gives the 64-character lowercase
string; `sha256` gives the 32 raw bytes, which is what you want when the digest
is going into a binary format or straight into another hash rather than onto a
screen.

## The one thing to know

There is no incremental interface. Both subs take the whole message as one
value and return the digest of it — there is no object to `.add` to and no
`.finalize`, so hashing a four-gigabyte file means having four gigabytes in
memory. For anything larger than comfortable, either shell out to the system's
own `shasum`, or use a pure-Raku `Digest` that offers a streaming API and
accept the slowdown.

The other thing to check before depending on it is the build. Because the
shared library is compiled during installation, this module can install
cleanly on your machine and fail on a container image with no toolchain — a
failure that arrives at deploy time rather than at test time. If that matters,
pin a pure-Raku fallback behind the same two-sub interface; the digests are
identical, so nothing above the call site needs to know which one ran.
