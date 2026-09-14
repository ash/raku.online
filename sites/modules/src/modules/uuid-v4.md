---
name: UUID::V4
version: 1.0.0
auth: zef:masukomi
kind: Distribution · identifiers
summary: Version-4 UUIDs and a predicate that recognises them — two subs, no
  state, no configuration, and a flaw in how the random bytes reach the string
  that is worth knowing before you rely on it.
status: full
suite: 1 file, green
tested: 2026-09-14
license: MIT
depends: Crypt::Random
raku-land: https://raku.land/zef:masukomi/UUID::V4
source: https://github.com/masukomi/UUID-V4
---

## What it is for

When rows need identifiers that several machines can mint at once without
asking each other, a large random number is the usual answer, and version 4 of
the UUID standard is the agreed way to write one down: 36 characters, five
hyphenated groups, with the version and variant pinned in fixed positions and
the remaining 122 bits random.

Sixty-nine lines and two exported subs, drawing from `Crypt::Random` — the
operating system's cryptographic source rather than the process's ordinary
PRNG.

## Both subs

```raku name="mint"
use UUID::V4;

my $id = uuid-v4();

say $id.chars;
say $id.substr(14, 1);
say $id.comb('-').elems;

say is-uuid-v4($id);
say is-uuid-v4('3f4a-not-a-uuid');
```

```output
36
4
4
True
False
```

The example asserts the shape rather than printing the value, since the value
differs every run: 36 characters, four hyphens, and the literal `4` at index 14
that makes it a *version 4* UUID rather than one of the time-based or
name-based versions. `is-uuid-v4` checks that same shape with a regex,
including the version nibble and the `8`/`9`/`a`/`b` variant nibble, so it
rejects a well-formed UUID of a different version as well as an outright
non-UUID.

## The one thing to know

The identifiers are **not uniformly random**, and the shortfall is large enough
to matter. Count the hex digits over a few hundred draws, leaving out the two
positions the standard fixes, and `a` to `f` never appear at all:

```raku name="bias"
use UUID::V4;

my %seen;
for ^500 {
    my $hex = uuid-v4().subst('-', '', :g);
    # index 12 is the version nibble and 16 the variant: both are fixed
    for ^32 -> $i { next if $i == 12 | 16; %seen{$hex.substr($i, 1)}++ }
}

say 'digits that occur: ', %seen.keys.sort.join('');
say 'digits that never: ', (flat '0'..'9', 'a'..'f').grep({ !%seen{$_} }).join('');
```

```output
digits that occur: 0123456789
digits that never: abcdef
```

Six of the sixteen possible digits are unreachable, and the ten that remain are
badly skewed — over 60,000 digits sampled, `3` turns up about twenty times more
often than `0`. The cause is a double encoding: the sixteen random bytes are
formatted into a hex *string*, and that string is then read back as raw bytes,
so what lands in the UUID is the hexadecimal of the **ASCII codes of hex
characters**. Those codes only ever span `0x30`–`0x39` and `0x61`–`0x66`, which
is precisely why every digit is a `3`, a `6`, or one of the low nibbles that
follow them. The same output appears under both engines, so this is the
module's arithmetic and not an interpreter difference.

Collisions are still unlikely at ordinary volumes, and nothing here breaks a
database key. But a version-4 UUID is often reached for precisely *because* it
is unguessable — a password-reset token, an unlisted URL, a capability handed
to a client — and for those this module does not deliver the 122 bits the
format implies. Prefer a UUID you build from `Crypt::Random` bytes directly, or
any generator whose output uses the whole alphabet. `is-uuid-v4` is unaffected
and remains a perfectly good validator for UUIDs from any source.
