---
name: Digest::MD5
version: 1.1.0
auth: zef:grondilu
kind: Distribution · crypto
summary: MD5 in forty-three lines of Raku — one sub, a message in and
  sixteen bytes out — for the content addresses and legacy checksums that
  still ask for it.
status: full
suite: 4 files, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:grondilu/Digest
source: https://github.com/grondilu/libdigest-raku
---

## What it is for

MD5 stopped being a security hash a long time ago and never stopped being a
name for content. Git object headers, ETags, `Content-MD5`, the checksum
column in an old table, the cache key a colleague chose in 2009: all of them
still want the same sixteen bytes, and a program that talks to any of them
needs to compute one. This unit does, in forty-three lines of Raku with
nothing underneath it — no C, no toolchain, no install-time build.

## One sub

```raku name="md5"
use Digest::MD5;

sub hex(Blob $b) { $b.list.map({ .fmt('%02x') }).join }

say hex(md5(''));
say hex(md5('abc'));
say hex(md5('The quick brown fox jumps over the lazy dog'));
say md5('abc').elems;
say hex(md5('abc')) eq hex(md5('abc'.encode));
```

```output
d41d8cd98f00b204e9800998ecf8427e
900150983cd24fb0d6963f7d28e17f72
9e107d9d372bb6826bd81d3542a419d6
16
True
```

Those are the RFC 1321 vectors, and the first is the digest of nothing — the
value to recognise when a file you meant to read came back empty. `md5` takes
a `Str` or a `Blob` and always answers sixteen raw bytes; there is no hex
helper, hence the three-line `hex` above. A `Str` is encoded as UTF-8 on the
way in, which is why the last line is `True`.

## The one thing to know

You cannot hash a decomposed string through the `Str` door. Raku normalises
string literals to composed form before `md5` ever sees them, so the two
spellings of an accented character are the same string and hash the same —
even though the two files on disk do not:

```raku name="normalisation"
use Digest::MD5;

sub hex(Blob $b) { $b.list.map({ .fmt('%02x') }).join }

my $composed   = "caf\x[00E9]";       # c a f  é
my $decomposed = "cafe\x[0301]";      # c a f  e  combining acute

say $composed.chars, ' ', $decomposed.chars, ' ', $composed eq $decomposed;
say hex(md5($composed));
say hex(md5($decomposed));

my $on-disk = Buf[uint8].new(0x63, 0x61, 0x66, 0x65, 0xCC, 0x81);
say hex(md5($on-disk));
```

```output
4 4 True
07117fe4a1ebd544965dc19573183da2
07117fe4a1ebd544965dc19573183da2
10a85865ce7a7d2f0dc3faf37c617a8d
```

The first two digests agree because both literals became the same four
characters. The third is the digest of the six bytes a decomposed file
actually contains, and it is a different value. If you are checksumming
bytes that came from somewhere — a file, a socket, a database column — hash
the `Blob`, never the `Str` you decoded it into.

Two smaller things. The distribution is named `Digest`, not `Digest::MD5`,
and installing it brings five more units with it: SHA-1, the SHA-2 family,
SHA-3, RIPEMD and HMAC. And `hmac` from that last unit has no default block
size — leave `:block-size` out and Raku++ binds it silently and computes the
wrong digest, where Rakudo throws. For MD5 it is 64.
