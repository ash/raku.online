---
name: Noise::Simplex
version: 0.1.2
auth: zef:apogee
kind: Distribution · graphics
summary: Seeded 2-D and 3-D simplex noise — bit-identical across engines, and
  it tiles every 147.8 units.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Math::Random
raku-land: https://raku.land/zef:apogee/Noise::Simplex
source: https://github.com/m-doughty/Noise-Simplex.git
---

## What it is for

Procedural terrain, cloud textures, organic-looking variation — anywhere you
want a smooth random field rather than per-pixel noise. Simplex noise is the
standard answer, and a seed makes the field reproducible.

## Sampling a field

```raku name="basics"
use Noise::Simplex;

my $s = Simplex.new(seed => 42);
my &n2 = $s.create-noise2d;

say 'a 5x5 grid at 0.5 spacing:';
for ^5 -> $y {
    say '  ', (^5).map({ sprintf('%+7.4f', n2($_ * 0.5, $y * 0.5)) }).join(' ');
}
say '';
say 'create-noise2d returns a ', &n2.WHAT.^name, ' taking ($x, $y).';
say 'create-noise3d gives you a three-argument one.';
```

```output
a 5x5 grid at 0.5 spacing:
  +0.0000 +0.5605 +0.0743 -0.4302 -0.0123
  -0.5300 +0.3072 +0.4294 -0.4270 +0.7855
  -0.1486 -0.5312 -0.4648 +0.0439 -0.4705
  +0.0544 +0.8661 +0.1420 +0.4978 +0.1713
  +0.0123 +0.6019 +0.2353 -0.4628 -0.1064

create-noise2d returns a Sub taking ($x, $y).
create-noise3d gives you a three-argument one.
```

```raku name="reproducible"
use Noise::Simplex;

say 'the same seed gives the same field, every time:';
my &a = Simplex.new(seed => 7).create-noise2d;
my &b = Simplex.new(seed => 7).create-noise2d;
say '  two objects, same seed  : ', so (^20).all.map({ a($_ * 0.3, 1.1) == b($_ * 0.3, 1.1) });
my &c = Simplex.new(seed => 8).create-noise2d;
say '  a different seed differs: ', a(0.25, 0.25) != c(0.25, 0.25);
say '';
say 'the range is [-1, 1]:';
my @vals = (^40 X ^40).map({ a(.[0] * 0.17, .[1] * 0.17) });
say '  min ', @vals.min.round(0.0001), '  max ', @vals.max.round(0.0001);
say '  all inside [-1, 1] : ', so @vals.all ~~ -1 .. 1;
say '  |mean| < 0.02      : ', @vals.sum.abs / @vals.elems < 0.02;
say '';
say 'the 2-D and 3-D fields are unrelated — n3(x, y, 0) is not n2(x, y):';
my &n3 = Simplex.new(seed => 7).create-noise3d;
say '  n2(0.25, 0.25)    = ', a(0.25, 0.25).round(0.000001);
say '  n3(0.25, 0.25, 0) = ', n3(0.25, 0.25, 0).round(0.000001);
```

```output
the same seed gives the same field, every time:
  two objects, same seed  : True
  a different seed differs: True

the range is [-1, 1]:
  min -0.9274  max 0.9139
  all inside [-1, 1] : True
  |mean| < 0.02      : True

the 2-D and 3-D fields are unrelated — n3(x, y, 0) is not n2(x, y):
  n2(0.25, 0.25)    = -0.193435
  n3(0.25, 0.25, 0) = 0.743268
```

Integer lattice points are not uniformly zero, unlike Perlin noise — some are
and some are not.

## The one thing to know

The field is not infinite. It tiles, repeating exactly every 256/√3 ≈ 147.8017
units along the x = y diagonal.

```raku name="tiling"
use Noise::Simplex;

my &n2 = Simplex.new(seed => 42).create-noise2d;
my $period = 256 / sqrt(3);
say 'claimed period along the diagonal : ', $period.round(0.0001);
say '';
my @diffs = (^20).map({
    my $t = $_ * 3.1;
    abs(n2($t, $t) - n2($t + $period, $t + $period))
});
say '  largest |f(p) - f(p + period)| : ', @diffs.max < 1e-9 ?? 'below 1e-9' !! @diffs.max;
say '  at HALF the period it differs  : ',
    abs(n2(1.0, 1.0) - n2(1 + $period/2, 1 + $period/2)) > 1e-6;
say '';
say 'the skewed lattice index is masked with +& 255, and there is no';
say 'option to change it. For terrain sampled over a few hundred units';
say 'this is invisible; over a few thousand the same landscape comes back.';
say '';
say 'any scaling of the input scales the period with it — a';
say 'noise(x/100, y/100) field repeats every ~14780 world units.';
```

```output
claimed period along the diagonal : 147.8017

  largest |f(p) - f(p + period)| : below 1e-9
  at HALF the period it differs  : True

the skewed lattice index is masked with +& 255, and there is no
option to change it. For terrain sampled over a few hundred units
this is invisible; over a few thousand the same landscape comes back.

any scaling of the input scales the period with it — a
noise(x/100, y/100) field repeats every ~14780 world units.
```

## The seed is taken modulo 2^64

```raku name="seed"
use Noise::Simplex;

sub fingerprint($seed) {
    my &n = Simplex.new(:$seed).create-noise2d;
    (^12).map({ n($_ * 0.37, 1.13).round(0.000001) }).join(',')
}
say 'congruent Int seeds give the identical field:';
say '  5 and 5 + 2**64     : ', fingerprint(5) eq fingerprint(5 + 2**64);
say '  -1 and 2**64 - 1    : ', fingerprint(-1) eq fingerprint(2**64 - 1);
say '  0 and 2**128        : ', fingerprint(0) eq fingerprint(2**128);
say '  -1 and 2**63 - 1    : ', fingerprint(-1) eq fingerprint(2**63 - 1);
say '';
say 'seed is required — Simplex.new with none refuses:';
my $r = try Simplex.new;
say '  Simplex.new -> ', $! ?? 'refused' !! 'built';
```

```output
congruent Int seeds give the identical field:
  5 and 5 + 2**64     : True
  -1 and 2**64 - 1    : True
  0 and 2**128        : True
  -1 and 2**63 - 1    : False

seed is required — Simplex.new with none refuses:
  Simplex.new -> refused
```

## Where the two engines differ

Nothing. Same-seed output matched to the last bit on both engines in every
sample taken for this page, which makes this module safe for reproducible
fixtures.

```raku name="portable"
use Noise::Simplex;

say 'one performance note: create-noise2d copies the 512-entry';
say 'permutation tables into a fresh closure on EVERY call. Build the';
say 'closure once, outside your loop:';
say '';
say '  my &n = Simplex.new(seed => $s).create-noise2d;   # once';
say '  for @points -> ($x, $y) { … n($x, $y) … }         # many';
say '';
my $s = Simplex.new(seed => 3);
my &n = $s.create-noise2d;
say 'a 400-sample heightmap row, quantised to five bands:';
say '  ', (^40).map({
    my $v = n($_ * 0.11, 0.5);
    <. - = # @>[ (($v + 1) / 2 * 4.999).Int ]
}).join;
say '';
say 'the permutation table itself is public, if you want to inspect it:';
say '  build-permutation-table gives ', $s.build-permutation-table.elems, ' entries.';
```

```output
one performance note: create-noise2d copies the 512-entry
permutation tables into a fresh closure on EVERY call. Build the
closure once, outside your loop:

  my &n = Simplex.new(seed => $s).create-noise2d;   # once
  for @points -> ($x, $y) { … n($x, $y) … }         # many

a 400-sample heightmap row, quantised to five bands:
  ##==####==-=#@@@#=-----=#@@@@@@#=-.-===-

the permutation table itself is public, if you want to inspect it:
  build-permutation-table gives 512 entries.
```
