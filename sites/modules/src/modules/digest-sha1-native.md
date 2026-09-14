---
name: Digest::SHA1::Native
version: 1.0.1
auth: zef:bduggan
kind: Distribution · crypto
summary: SHA-1 through a C implementation compiled at install time — two
  subs, the raw digest and the hex string, for the checksum and lookup-key
  uses where SHA-1 is still what the other side expects.
status: full
suite: 12 files, green
tested: 2026-09-14
license: Artistic-2.0
depends: LibraryMake
raku-land: https://raku.land/zef:bduggan/Digest::SHA1::Native
source: https://github.com/bduggan/raku-digest-sha1-native
---

## What it is for

SHA-1 is no longer a signature algorithm and is still everywhere as a name
for content: git object ids, the blob ids in a Raku module store, the
checksums an old API insists on. When a program needs to compute those over
anything bigger than a few kilobytes, the pure-Raku `Digest::SHA1` costs
seconds per megabyte and this distribution costs milliseconds, because the
work is done by a small C file that `LibraryMake` compiles when the module
is installed. Eleven distributions depend on it for exactly that.

## Both subs

```raku name="sha1"
use Digest::SHA1::Native;

say sha1-hex('hello');
say sha1-hex('');
say sha1('hello').elems;
say sha1-hex('hello'.encode) eq sha1-hex('hello');

my $t0 = now;
sha1-hex('x' x 1_000_000);
say now - $t0 < 1;
```

```output
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
da39a3ee5e6b4b0d3255bfef95601890afd80709
20
True
True
```

A `Str` is encoded as UTF-8 before hashing, so the two spellings of `hello`
agree; a `Blob` is hashed as it is. The second digest is SHA-1 of nothing —
worth recognising, because it is what you get when the file you meant to
read came back empty. The last line is the reason to install it: a
megabyte in well under a second, where the Raku implementation takes about
twenty-five.

## The one thing to know

The library is built at install time and stored beside the module, and how
it is stored decides which engine can find it. Rakudo opens a compiled
resource under a name derived from the blob's id, and until this week a
store written by `rakupp install` held the library under the bare id only —
so the module worked under Raku++ and died under Rakudo on the same machine
with *Cannot locate native library*. The installer now writes the file under
both names, and a fresh `rakupp install Digest::SHA1::Native` leaves the
module usable by either engine, which is what the store promises. A store
filled before the fix needs `rakupp reinstall` of this distribution for
Rakudo's sake.

There is no incremental interface: both subs take the whole message, so a
file has to be in memory to be hashed. For anything that does not fit, the
system's `shasum` is the honest fallback.
