---
name: Algorithm::SetUnion
version: 0.0.1
auth: titsuki
kind: Distribution · algorithms
summary: A disjoint-set forest over the integers 0 ..^ size, with union by
  subtree size and full path compression, and the node array exposed.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/titsuki/Algorithm::SetUnion
source: git://github.com/titsuki/p6-Algorithm-SetUnion.git
---

## What it is for

"Are these two things in the same group, and if not, merge their groups" is
the question under connected components, under Kruskal's minimum spanning
tree, under image segmentation, and under any equivalence-class bookkeeping.
Answered naively it is quadratic; answered with a disjoint-set forest it is
very nearly constant.

This distribution is that forest, with both standard optimisations: merge the
smaller tree under the larger, and flatten the path on every lookup.

## Unioning and finding

```raku name="union"
use Algorithm::SetUnion;

my $u = Algorithm::SetUnion.new(size => 8);

say 'a fresh forest — every element is its own root:';
say '  find(i) for 0..7 : ', (^8).map({ $u.find($_) }).join(' ');
say '  .size            : ', $u.size, '   .nodes.elems : ', $u.nodes.elems;
say '';
say 'union(0,1) -> ', $u.union(0, 1);
say 'union(2,3) -> ', $u.union(2, 3);
say 'union(1,3) -> ', $u.union(1, 3);
say 'union(4,5) -> ', $u.union(4, 5);
say '  find(i) for 0..7 : ', (^8).map({ $u.find($_) }).join(' ');
say '';
say 'union of two elements already together -> ', $u.union(0, 3);
say 'union of an element with itself        -> ', $u.union(0, 0);
```

```output
a fresh forest — every element is its own root:
  find(i) for 0..7 : 0 1 2 3 4 5 6 7
  .size            : 8   .nodes.elems : 8

union(0,1) -> True
union(2,3) -> True
union(1,3) -> True
union(4,5) -> True
  find(i) for 0..7 : 0 0 0 0 4 4 6 7

union of two elements already together -> False
union of an element with itself        -> False
```

`union` returns `True` when it actually merged something and `False` when the
two were already in one set — which is the only same-set test the class
offers. There is no `connected` or `same-set` method.

## Reading the components out

```raku name="components"
use Algorithm::SetUnion;

my $u = Algorithm::SetUnion.new(size => 8);
$u.union(0, 1); $u.union(2, 3); $u.union(1, 3); $u.union(4, 5);

my %g;
%g.push($u.find($_) => $_) for ^8;
for %g.keys.sort({ +$_ }) -> $r {
    say "root $r : ", %g{$r}.list.sort.join(','),
        "   nodes[$r].size = ", $u.nodes[$r].size;
}
say '';
say 'the size of the component holding 1 : ', $u.nodes[$u.find(1)].size;
say 'nodes[1].size, which is NOT that    : ', $u.nodes[1].size;
```

```output
root 0 : 0,1,2,3   nodes[0].size = 4
root 4 : 4,5   nodes[4].size = 2
root 6 : 6   nodes[6].size = 1
root 7 : 7   nodes[7].size = 1

the size of the component holding 1 : 4
nodes[1].size, which is NOT that    : 1
```

`.size` on the forest is the **capacity** you constructed it with, not the
number of components. The size of the component containing `$i` is
`$u.nodes[$u.find($i)].size` — and `nodes[$j].size` for a non-root `$j` is a
stale leftover from when `$j` was a root.

## Path compression

```raku name="compression"
use Algorithm::SetUnion;

my $u = Algorithm::SetUnion.new(size => 4);
$u.union(0, 1);         # root 0, size 2
$u.union(2, 3);         # root 2, size 2
$u.union(0, 2);         # equal sizes, so 2 hangs under 0 and 3 sits at depth 2

say 'parents before find(3) : ', (^4).map({ $u.nodes[$_].parent }).join(' ');
say 'find(3) = ', $u.find(3);
say 'parents after  find(3) : ', (^4).map({ $u.nodes[$_].parent }).join(' ');
```

```output
parents before find(3) : 0 0 0 2
find(3) = 0
parents after  find(3) : 0 0 0 0
```

The lookup rewrites every parent pointer it walked past, so the next lookup on
any of them is one step.

## The one thing to know

`find` returns a root index, and that index is not a stable identity for the
set. A later union somewhere else can change what `find` returns for an
element that never moved.

```raku name="root-trap"
use Algorithm::SetUnion;

my $u = Algorithm::SetUnion.new(size => 6);

$u.union(0, 1);
say 'after union(0,1)               : find(0) = ', $u.find(0);

$u.union(2, 3); $u.union(4, 5); $u.union(2, 4);
say 'after three unions on the other side : find(0) = ', $u.find(0),
    '   find(2) = ', $u.find(2);

$u.union(0, 2);
say 'after union(0,2)               : find(0) = ', $u.find(0),
    '   find(2) = ', $u.find(2);
say '';
say 'element 0 never moved, and its root id changed anyway';
```

```output
after union(0,1)               : find(0) = 0
after three unions on the other side : find(0) = 0   find(2) = 2
after union(0,2)               : find(0) = 2   find(2) = 2

element 0 never moved, and its root id changed anyway
```

Because the merge is by size, the **larger** component's root survives.
Element 0 was its own root for three operations and then stopped being one.
Cache a root as a key in a hash and your bookkeeping silently desynchronises
from the forest.

Re-read `find` every time you need the identity, or maintain your own mapping
and update it on every `True` from `union`.

## Where the two engines differ

Only in a warning. `Algorithm::SetUnion.new` with **no** `size` silently
produces an empty structure whose `.size` is the `Int` type object — Rakudo at
least emits `Use of uninitialized value of type Int in numeric context` from
`BUILD`, and Raku++ says nothing at all. `size => -3` is accepted on both and
also produces an empty structure.

Two more things, identical on both engines. Any out-of-range index, including
`find(4)` on a size-4 forest, dies with `Cannot look up attributes in a
Algorithm::SetUnion::Node type object` — a message that does not mention
indices — while `find(-1)` gives a different message again. And `@.nodes`
exposes `is rw` attributes, so a caller can corrupt the forest by writing
through them.

Correctness was cross-checked against a naive scan-based implementation over
nine unions on a twelve-element set: identical partitions and identical
`union` return values, on both engines.
