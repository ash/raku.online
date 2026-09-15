---
name: Math::DistanceFunctions::Native
version: 0.1.2
auth: zef:antononcube
kind: Distribution · maths
summary: Vector distance and similarity primitives backed by a bundled C
  implementation — Euclidean, squared Euclidean, cosine, dot product and norm.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: NativeHelpers::Array, Math::DistanceFunctions::Edit
raku-land: https://raku.land/zef:antononcube/Math::DistanceFunctions::Native
source: https://github.com/antononcube/Raku-Math-DistanceFunctions-Native.git
---

## What it is for

Comparing embeddings is a tight loop over long vectors, and a pure-Raku
implementation spends all its time boxing numbers. Anything doing nearest
neighbour over a few thousand 768-dimension vectors will notice.

This distribution puts the five primitives in C and compiles them at install
time.

## The distances

```raku name="distances"
use Math::DistanceFunctions::Native;

my @a = [1e0, 2e0, 3e0];
my @b = [4e0, 5e0, 6e0];

say 'euclidean-distance         : ', euclidean-distance(@a, @b);
say 'squared-euclidean-distance : ', squared-euclidean-distance(@a, @b);
say 'dot-product                : ', dot-product(@a, @b);
say 'cosine-distance            : ', cosine-distance(@a, @b);
say 'norm(@a)                   : ', norm(@a);
say '';
say 'checks:';
say '  sqrt(27)          = ', 27.sqrt;
say '  1*4 + 2*5 + 3*6   = ', 1*4 + 2*5 + 3*6;
say '  sqrt(1+4+9)       = ', 14.sqrt;
```

```output
euclidean-distance         : 5.196152422706632
squared-euclidean-distance : 27
dot-product                : 32
cosine-distance            : 0.025368153802923787
norm(@a)                   : 3.7416573867739413

checks:
  sqrt(27)          = 5.196152422706632
  1*4 + 2*5 + 3*6   = 32
  sqrt(1+4+9)       = 3.7416573867739413
```

Every value checks out against the closed form. `cosine-distance` is
`1 − cos θ`, so it is 0 for parallel vectors and 2 for antiparallel ones.

## Identical vectors

```raku name="identical"
use Math::DistanceFunctions::Native;

my @a = [1e0, 2e0, 3e0];
say 'euclidean(a, a) : ', euclidean-distance(@a, @a);
say 'cosine(a, a)    : ', cosine-distance(@a, @a);
say 'dot(a, a)       : ', dot-product(@a, @a);
say 'norm(a) squared : ', norm(@a) ** 2;
```

```output
euclidean(a, a) : 0
cosine(a, a)    : 0
dot(a, a)       : 14
norm(a) squared : 14
```

## The one thing to know

A zero vector makes `cosine-distance` return `NaN` rather than raising — and
`NaN` compares false against everything.

```raku name="nan-trap"
use Math::DistanceFunctions::Native;

my @a = [1e0, 2e0, 3e0];
my @zero = [0e0, 0e0, 0e0];

say 'cosine-distance(a, zero)    : ', cosine-distance(@a, @zero);
say 'euclidean-distance(a, zero) : ', euclidean-distance(@a, @zero);
say '';
my $nan = cosine-distance(@a, @zero);
say 'every comparison against it is false:';
say '  NaN < 1  : ', $nan < 1;
say '  NaN > 1  : ', $nan > 1;
say '  NaN == NaN : ', $nan == $nan;
say '';
say 'so in a .sort by cosine distance it lands wherever the sort puts it,';
say 'silently, rather than blowing up.';
```

```output
cosine-distance(a, zero)    : NaN
euclidean-distance(a, zero) : 3.7416573867739413

every comparison against it is false:
  NaN < 1  : False
  NaN > 1  : False
  NaN == NaN : False

so in a .sort by cosine distance it lands wherever the sort puts it,
silently, rather than blowing up.
```

In the module's natural setting — ranking candidate vectors by similarity — a
single zero vector in the corpus does not crash anything. It sorts to an
arbitrary position, because every comparison involving it is false.

A zero vector is not exotic: it is what an all-zero embedding, an empty
document or a failed encode produces. `euclidean-distance` handles the same
input fine, so the defect is specific to the normalised measures and easy to
miss in testing.

Filter zero vectors out of the corpus, or check `.isNaN` on the result.

## Where the two engines differ

Nowhere. Every value in this page was identical on Raku++ and Rakudo.

Two more things to guard at your own call site, both the same on both engines
and both returning something plausible rather than complaining.

**Mismatched vector lengths return `Nil`**, not an error — so comparing a
768-dimension embedding against a 512-dimension one produces an undefined
value that surfaces as a confusing failure much later. **Empty vectors return
`0e0`**, which reads as "identical" and is the most misleading possible
answer.

And the return type is not stable: `Num` input gives a `Num`, `Int` input
gives a `Num` with an `e0` suffix in its gist, and the exact cases give
integers. Do not assert on `.WHAT`.

The distribution compiles C at install time through its own builder, so it
needs a toolchain on the target machine.
