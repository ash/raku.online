---
name: Digest::HMAC
version: 1.0.7
auth: zef:jjmerelo
kind: Distribution · crypto
summary: Keyed message authentication (RFC 2104) over any digest you hand
  it — verify a webhook signature or sign an API request in one line, in
  pure Raku.
status: full
depends: Digest
suite: 2 files, green
tested: 2026-08-28
raku-land: https://raku.land/zef:jjmerelo/Digest::HMAC
source: https://github.com/JJ/Raku-Digest-HMAC
---

## What it is for

A hash proves a message was not corrupted; an HMAC proves it was not
corrupted **and came from someone holding the key**. That is the mechanism
behind webhook signatures, signed cookies, and most API request signing.
This module is the RFC 2104 construction in about twenty lines of Raku —
and instead of hard-coding a hash, `hmac` takes the digest *function* as an
argument, so one implementation serves them all:

```raku name="first-hmac"
use Digest::HMAC;
use Digest::SHA1;

say hmac-hex('key', 'The quick brown fox jumps over the lazy dog', &sha1);
```

```output
de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9
```

That output is the published test vector for HMAC-SHA1 — you can check it
against any other language's `hmac` library, and this page's build
effectively does. The digest functions come from the
[Digest](https://raku.land/zef:grondilu/Digest) distribution, which is
installed as a dependency: `use Digest::SHA1`, `use Digest::SHA2` (for
`sha256`, `sha384`, `sha512`), `use Digest::MD5`, and so on. Anything that
maps a `Blob` to a `Blob` works, including a digest you wrote yourself.

## Verifying a webhook

The everyday use: a service POSTs you JSON and puts
`sha256=<hex>` in a header. You recompute the tag over the raw body with
the shared secret and compare:

```raku name="webhook-signature"
use Digest::HMAC;
use Digest::SHA2;

my $secret  = 'webhook-secret';
my $payload = '{"action":"opened","number":1}';

my $expected = 'sha256=' ~ hmac-hex($secret, $payload, &sha256);
say $expected;

my $header = 'sha256=b41572a08af38c59c7736ef55ac89a408ce86f4ac8474b077a7a8962ab87bd15';
say $header eq $expected;
```

```output
sha256=b41572a08af38c59c7736ef55ac89a408ce86f4ac8474b077a7a8962ab87bd15
True
```

Two production notes the module leaves to you. Compute over the **raw
request body**, exactly as received — re-serialized JSON reorders keys and
the tag dies. And `eq` bails out at the first differing character, which
in principle leaks timing; for internet-facing verification, compare
digests of the two strings, or use a constant-time comparison.

## Raw bytes, and the blocksize trap

`hmac` (without `-hex`) returns the tag as a `Blob`, for when the protocol
wants base64 or raw bytes rather than hex. And both subs take a fourth
argument, the hash's **block size**, defaulting to 64 — which is correct
for MD5, SHA-1 and SHA-256, and silently wrong for SHA-384 and SHA-512,
whose blocks are 128 bytes:

```raku name="blocksize"
use Digest::HMAC;
use Digest::SHA2;

my $tag = hmac('key', 'message', &sha256);
say $tag ~~ Blob;
say $tag.elems;

say hmac-hex('key', 'message', &sha512, 128).substr(0, 16);
```

```output
True
32
e477384d7ca229dd
```

With the `128`, the SHA-512 tag above matches every other HMAC
implementation; leave it at the default and you get a well-formed value
that nothing else on earth agrees with — the kind of bug that surfaces as
"signature mismatch" in someone else's log. If you use `sha512`, write
the `128`.

## Where the two engines differ

One cosmetic thing, kept off the examples above: the tag's type prints as
`Blob[uint8]` under Rakudo and plain `Blob` under Raku++ — the bytes, the
`elems`, and every hex digit are identical, so smartmatching `~~ Blob` is
the portable spelling.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install Digest::HMAC`, which brings the pure-Raku
   `Digest` distribution with it.
3. **Test** — the distribution's own suite: 2 files, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built — and the three tags shown were additionally checked
   against an independent implementation (Python's `hmac`), so the page
   agrees with the world, not just with itself.
