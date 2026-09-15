---
name: Data::RandomKeep
version: 0.1.1
auth: zef:lucs
kind: Distribution · sampling
summary: Reservoir sampling — keep N items from a stream of unknown length in
  constant memory, and get them back sorted by value.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lucs/Data::RandomKeep
source: git://github.com/lucs/Data-RandomKeep.git
---

## What it is for

You want a random sample of a stream, you do not know how long the stream is,
and you cannot hold it in memory. Reservoir sampling solves exactly that: keep
N items, and give each item offered an equal chance of being among them,
whatever N and however many items arrive.

## Sampling

```raku name="basics"
use Data::RandomKeep;

my $k = Data::RandomKeep.new(3);
say 'nb-to-keep : ', $k.nb-to-keep;
$k.offer($_) for 1 .. 100;
say 'nb-seen    : ', $k.nb-seen;
say 'nb-kept    : ', $k.nb-kept;
my @kept = $k.kept;
say 'kept       : ', @kept.elems, ' items, all from 1..100 : ',
    so @kept.all ~~ 1..100;
say '  distinct : ', @kept.unique.elems == @kept.elems;
say '';
say 'offer is slurpy and flattens, so a whole list can go in at once:';
my $b = Data::RandomKeep.new(2);
$b.offer(1 .. 5);
say '  nb-seen after offer(1..5) : ', $b.nb-seen;
```

```output
nb-to-keep : 3
nb-seen    : 100
nb-kept    : 3
kept       : 3 items, all from 1..100 : True
  distinct : True

offer is slurpy and flattens, so a whole list can go in at once:
  nb-seen after offer(1..5) : 5
```

## Uniformity

```raku name="uniform"
use Data::RandomKeep;

my %count;
my $trials = 20_000;
for ^$trials {
    my $k = Data::RandomKeep.new(1);
    $k.offer($_) for ^20;
    %count{$k.kept[0]}++;
}
say "keep 1 of 20, $trials trials";
say '  distinct items ever kept : ', %count.keys.elems;
my $expected = $trials / 20;
my $sigma = sqrt($expected * 19 / 20);
say '  expected per item        : ', $expected.Int;
say '  every count within 5 sigma : ',
    so %count.values.all ~~ ($expected - 5 * $sigma) .. ($expected + 5 * $sigma);
say '  total kept == trials     : ', %count.values.sum == $trials;
```

```output
keep 1 of 20, 20000 trials
  distinct items ever kept : 20
  expected per item        : 1000
  every count within 5 sigma : True
  total kept == trials     : True
```

Nothing above asserts a value — the sample is random, and these are the
properties that hold every run.

## The one thing to know

`.kept` does not return the items in offer order. It sorts them by their own
numeric value — and that sort makes `.kept` **throw** for any non-numeric
item.

```raku name="sorted"
use Data::RandomKeep;

my $k = Data::RandomKeep.new(4);
$k.offer(40, 30, 20, 10);
say 'offered : 40, 30, 20, 10';
say 'kept    : ', $k.kept.join(', '), '   <- ascending, not offer order';
say '';
say 'offered words : delta alpha charlie bravo';
say 'kept          : it throws — the sort numifies each word, and';
say '                "delta" is not a number';
say '';
say 'the method is';
say '  return @!kept.map({ $_[1] }).sort({ $^a[0] <=> $^b[0] });';
say 'and the .map has ALREADY replaced each [nb-seen, item] pair with the';
say 'bare item — so the comparator`s $^a[0] indexes the ITEM, which for a';
say 'scalar is the item itself, numified by <=>.';
say '';
say 'so the module`s headline application — keeping N random LINES of a';
say 'file — cannot work directly. Offer INDICES and keep the lines';
say 'yourself; offer is a flattening slurpy, so a tuple would not survive';
say 'anyway:';
my @lines = <first second third fourth fifth>;
my $idx = Data::RandomKeep.new(2);
$idx.offer(^@lines);
my @chosen = $idx.kept.map({ @lines[$_] });
say '  sampled 2 of ', @lines.elems, ' lines : ', @chosen.elems, ' back';
say '  all of them real lines           : ', so @chosen.all (elem) @lines;
```

```output
offered : 40, 30, 20, 10
kept    : 10, 20, 30, 40   <- ascending, not offer order

offered words : delta alpha charlie bravo
kept          : it throws — the sort numifies each word, and
                "delta" is not a number

the method is
  return @!kept.map({ $_[1] }).sort({ $^a[0] <=> $^b[0] });
and the .map has ALREADY replaced each [nb-seen, item] pair with the
bare item — so the comparator`s $^a[0] indexes the ITEM, which for a
scalar is the item itself, numified by <=>.

so the module`s headline application — keeping N random LINES of a
file — cannot work directly. Offer INDICES and keep the lines
yourself; offer is a flattening slurpy, so a tuple would not survive
anyway:
  sampled 2 of 5 lines : 2 back
  all of them real lines           : True
```

## The constructor takes a positional

```raku name="constructor"
use Data::RandomKeep;

say 'new(6).nb-to-keep             : ', Data::RandomKeep.new(6).nb-to-keep;
say 'new(:nb-to-keep(6)).nb-to-keep: ', Data::RandomKeep.new(nb-to-keep => 6).nb-to-keep;
say 'new().nb-to-keep              : ', Data::RandomKeep.new.nb-to-keep;
say '';
say '`new` is overridden with a POSITIONAL parameter, so the named form';
say 'lands in the implicit *%_ and is discarded. .bless(:nb-to-keep(6))';
say 'does work, which makes the failure look arbitrary — pass the';
say 'positional.';
say '';
say 'and new(0) is accepted and keeps nothing, forever, without complaint:';
my $z = Data::RandomKeep.new(0);
$z.offer(1, 2, 3);
say '  new(0): nb-seen=', $z.nb-seen, ' nb-kept=', $z.nb-kept;
```

```output
new(6).nb-to-keep             : 6
new(:nb-to-keep(6)).nb-to-keep: 1
new().nb-to-keep              : 1

`new` is overridden with a POSITIONAL parameter, so the named form
lands in the implicit *%_ and is discarded. .bless(:nb-to-keep(6))
does work, which makes the failure look arbitrary — pass the
positional.

and new(0) is accepted and keeps nothing, forever, without complaint:
  new(0): nb-seen=3 nb-kept=0
```

## Where the two engines differ

Nothing now. Until Raku++ 3.28.0 the reservoir silently lost items there:
the module's slot chooser is

```raku fragment
@!kept[
    $!nb-kept < $!nb-to-keep ?? $!nb-kept++ !! $!nb-to-keep.rand;
] = [$!nb-seen, $item];
```

and an element assignment used to evaluate its subscript **twice** — once to
decide whether the subscript named many elements or one, and again to reach
the slot. So `$!nb-kept++` advanced by two per stored item and the write
landed in the wrong slot; 13.7% of draws came back short, and only for
reservoirs larger than one, which is the case nobody tests first.

```raku name="reservoir"
use Data::RandomKeep;

my $short = 0;
my $with-any = 0;
for ^2000 {
    my $k = Data::RandomKeep.new(3);
    $k.offer($_) for ^10;
    my @kept = $k.kept;
    $short++ unless @kept.elems == 3;
    $with-any++ if @kept.grep({ !.defined });
}
say '2000 draws of keep-3-from-10:';
say '  draws that came back short      : ', $short;
say '  draws containing an undefined   : ', $with-any;
say '';
say 'both zero on both engines. A keep-1 reservoir always indexed slot 0,';
say 'which is why the old bug never showed in the obvious first test.';
```

```output
2000 draws of keep-3-from-10:
  draws that came back short      : 0
  draws containing an undefined   : 0

both zero on both engines. A keep-1 reservoir always indexed slot 0,
which is why the old bug never showed in the obvious first test.
```
