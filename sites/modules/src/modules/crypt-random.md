---
name: Crypt::Random
version: 0.4.1
auth: github:skinkade
kind: Distribution · crypto
summary: Random bytes and integers from the operating system's cryptographic
  source instead of the language's PRNG — a buffer, an integer, an unbiased
  draw below a bound, and a version-4 UUID assembled from them.
status: full
suite: 3 files, green
tested: 2026-09-14
depends: if
raku-land: https://raku.land/github:skinkade/Crypt::Random
source: https://github.com/skinkade/crypt-random
---

## What it is for

`rand`, `pick` and `roll` draw from a generator built for simulations: fast,
seedable, and predictable to anyone who has seen enough of its output. A
session token, a password-reset link or a nonce needs the other kind of
random — bytes nobody can predict — and every operating system keeps a
source of those. On Unix it is `/dev/urandom`; on Windows the system crypto
API.

This distribution is the forty-four lines that read it. `crypt_random_buf`
returns that many bytes as a `Buf`; `crypt_random` reads four of them (or
as many as you ask for) into an `Int`; `crypt_random_uniform` gives an
integer below a bound *without* the bias that `% $bound` would introduce,
by the rejection method `arc4random_uniform` uses. `Crypt::Random::Extra`
adds a prime, a sample from a list, and a UUID. Seven distributions draw
from it, `UUID::V4` among them.

## Draws

```raku sample name="draws"
use Crypt::Random;
use Crypt::Random::Extra;

say crypt_random_buf(8);
say crypt_random(2);
say crypt_random_uniform(6);
say crypt_random_UUIDv4;
say crypt_random_sample(['a'..'f'], 3);
```

```output
Buf:0x<7A 03 D1 5E 9C 2B 44 F0>
41207
3
9f1c2e8a-6b4d-4c3e-8a5f-0d2b7e4c9a11
[e b e]
```

Those change every run, so the page checks the things about them that do
not: the length of a buffer, the range of an integer, that a bounded draw
covers its whole range and nothing outside it, and — since it is the reason
this page exists next to the `UUID::V4` one — that the UUID uses every hex
digit:

```raku name="properties"
use Crypt::Random;
use Crypt::Random::Extra;

say crypt_random_buf(16).elems;
say so (^500).map({ crypt_random(2) }).all < 65536;
my @draws = (^3000).map({ crypt_random_uniform(6) });
say @draws.unique.sort.join(',');
say so @draws.Bag.values.all > 400;

my %seen;
for ^200 {
    my $hex = crypt_random_UUIDv4.subst('-', '', :g);
    for ^32 -> $i { next if $i == 12 | 16; %seen{$hex.substr($i, 1)}++ }
}
say %seen.keys.sort.join;
```

```output
16
True
0,1,2,3,4,5
True
0123456789abcdef
```

The last line is the point. The `UUID::V4` distribution formats its random
bytes into hex and then reads that text back as bytes, so its identifiers
never contain `a` to `f` and lean hard on `3` and `6`. This one masks the
version and variant bits into the raw buffer and formats once, and the whole
alphabet turns up — 3,200 digits sampled here, sixteen values seen. If you
want a v4 UUID that is as random as the format promises, this is the
generator, two lines longer to call.

## The one thing to know

Divide by the bound, do not take the remainder. `crypt_random() % 6` is the
obvious spelling and it is biased: 2³² is not a multiple of 6, so the low
values come up slightly more often than the high ones — by one part in a
few hundred million for six faces, which is nothing for a game and exactly
what a cryptographer looks for. `crypt_random_uniform(6)` throws away the
draws that would tilt it and returns an even distribution, and it is the
sub to use for anything with a range.

The dependency named above is worth a sentence too. The `if` distribution
exists for one adverb: `use Crypt::Random::Nix:if(!$*DISTRO.is-win)` loads
the Unix reader on Unix and skips it on Windows. Under the Raku++ 3.28.0
release, `if`'s own test suite failed and `rakupp install Crypt::Random` was
refused with it — the engine now reads the `:if` pair itself, the suite
passes, and the install goes through.
