---
name: UUID
version: 1.0.0
auth: github:retupmoca
kind: Distribution · identifiers
summary: Version-4 UUIDs — 122 random bits in the one format every
  database, log pipeline and API on earth already accepts.
status: full
suite: 1 file, green
tested: 2026-08-28
raku-land: https://raku.land/github:retupmoca/UUID
source: https://github.com/retupmoca/P6-UUID
---

## What it is for

You need an identifier that is unique without asking anyone — no counter
to coordinate, no database round-trip, safe to mint on two machines at
once. That is what a version-4 UUID is: 122 random bits dressed in the
`8-4-4-4-12` hex format everything already parses. This module makes them
and nothing else:

```raku sample name="mint-one"
use UUID;

my $id = UUID.new;
say "report-{$id}.json";
```

```output
report-6decb98e-62d2-4532-abff-e5f3139f4ade.json
```

Interpolation calls `.Str`, which renders the canonical dashed form. Note
that `say $id` on its own prints the object's constructor gist — bytes and
all — so when you want the familiar string, interpolate or call `.Str`
yourself.

## What the format promises

Two nibbles in a v4 UUID are not random: the third group starts with `4`
(the version) and the fourth with one of `8 9 a b` (the variant). Those
are the bits a validator checks, and this page can check them the same
way — everything below is deterministic even though every UUID is fresh:

```raku name="format-guarantees"
use UUID;

my $id = UUID.new;
say $id.Str.chars;
say so $id.Str ~~ /^ <xdigit>**8 '-' <xdigit>**4 '-' 4 <xdigit>**3 '-' <[89ab]> <xdigit>**3 '-' <xdigit>**12 $/;
say $id.version;
say $id.Blob.elems;
say UUID.new.Str ne UUID.new.Str;
```

```output
36
True
4
16
True
```

`.Blob` hands you the sixteen raw bytes for the protocols that want
binary, and `.version` reports the `4`. The last line is the practical
guarantee: two calls, two values — with 122 random bits, a collision is
not something to code for.

Only version 4 is implemented; `UUID.new(:version(1))` — the
timestamp-and-MAC flavour — dies with *UUID version 1 not supported*,
which is the module telling you its whole scope honestly. If you need the
newer sortable kinds (v7), this is not the distribution for them.

## Where the two engines differ

Nothing on this page. The random source, the version and variant bit
stamping, the string form and the raw bytes behave identically under
Raku++ and Rakudo — including the unhelpful default `say` gist, which both
engines print the same way.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install UUID`; it depends on nothing outside the
   core.
3. **Test** — the distribution's own suite: 1 file, green.
4. **Run** — every example on this page under each engine as the site is
   built — the first example once per engine (its output is fresh every
   run, so it is shown as one run), the second twice, with every line
   compared.

Seventeen distributions depend on it, which for a module this small —
one class, forty lines — is the ecosystem saying the scope is exactly
right.
