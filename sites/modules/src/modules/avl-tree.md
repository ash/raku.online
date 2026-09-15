---
name: AVL-Tree
version: 0.0.2
auth: zef:tbrowder
kind: Distribution · data structures
summary: A height-balanced binary search tree holding one key per node, with
  an optional payload, rebalancing by rotation on insert and delete.
status: partial
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:tbrowder/AVL-Tree
source: git://github.com/tbrowder/AVL-Tree.git
---

## What it is for

A plain binary search tree degenerates into a linked list when the keys arrive
in order, which is the common case. An AVL tree fixes that by rotating after
every insert and delete so no subtree is ever more than one level taller than
its sibling — which keeps every operation logarithmic whatever order the keys
came in.

This distribution is that, translated from a Rosetta Code Java version.

## Building a tree

```raku name="insert"
use AVL-Tree;

my $t = AVL-Tree.new;
$t.insert($_) for 5, 3, 8, 1, 4, 7, 9, 2, 6;

say 'keys, in order : ', $t.keys.join(' ');
say 'nodes          : ', $t.nodes.elems;
say 'root key       : ', $t.root.key;
say '';
print 'show-keys      : '; $t.show-keys;
print 'show-balances  : '; $t.show-balances;
```

```output
keys, in order : 1 2 3 4 5 6 7 8 9
nodes          : 9
root key       : 5

show-keys      : 1 2 3 4 5 6 7 8 9 
show-balances  : 1 0 -1 0 0 0 -1 -1 0 
```

Nine sequential inserts give a tree rooted at 5 with every balance in −1..1.
The balancing works, which is the hard part.

`show-keys` and `show-balances` **print** rather than returning — use `.keys`
and `.nodes` to get data.

## Payloads and deletion

```raku name="payload"
use AVL-Tree;

my $t = AVL-Tree.new;
$t.insert($_, data => "d$_") for 5, 8, 9;
say 'find(8).data : ', $t.find(8).data;
say '';
my $d = AVL-Tree.new;
$d.insert($_) for 1 .. 9;
say 'before        : ', $d.keys.join(' ');
$d.delete(3);
say 'after del 3   : ', $d.keys.join(' ');
$d.delete(1, 9);
say 'after del 1,9 : ', $d.keys.join(' ');
$d.delete(42);
say 'after del 42  : ', $d.keys.join(' ');
```

```output
find(8).data : d8

before        : 1 2 3 4 5 6 7 8 9
after del 3   : 1 2 4 5 6 7 8 9
after del 1,9 : 2 4 5 6 7 8
after del 42  : 2 4 5 6 7 8
```

`delete` is slurpy, so several keys go in one call, and deleting an absent key
is a quiet no-op.

## Return values

```raku name="returns"
use AVL-Tree;

my $t = AVL-Tree.new;
say 'the first insert into an empty tree returns a : ', $t.insert(10).^name;
say 'every insert after that returns a             : ', $t.insert(20).^name;
say 'an insert of a key already present            : ', $t.insert(10);
say 'an insert of a fresh key                      : ', $t.insert(30);
```

```output
the first insert into an empty tree returns a : AVL-Tree::Node
every insert after that returns a             : Bool
an insert of a key already present            : False
an insert of a fresh key                      : True
```

## The one thing to know

`find` only ever returns a node that lies on the **right spine** of the tree.
For every other key — including keys that are definitely present — it returns
`Empty`.

```raku name="find-trap"
use AVL-Tree;

my $t = AVL-Tree.new;
$t.insert($_) for 5, 3, 8, 1, 4, 7, 9, 2, 6;

say 'the tree holds : ', $t.keys.join(' ');
say '';
say 'key  present?  find() returns';
for 1 .. 10 -> $k {
    my $found = $t.find($k);
    say sprintf('%3d  %-9s  %s', $k,
        $t.keys.grep($k) ?? 'yes' !! 'no',
        $found ~~ AVL-Tree::Node ?? 'Node(key=' ~ $found.key ~ ')' !! 'Empty');
}
say '';
say 'the right spine from the root : ', gather {
    my $n = $t.root;
    while $n { take $n.key; $n = $n.right }
}.join(' ');
```

```output
the tree holds : 1 2 3 4 5 6 7 8 9

key  present?  find() returns
  1  yes        Empty
  2  yes        Empty
  3  yes        Empty
  4  yes        Empty
  5  yes        Node(key=5)
  6  yes        Empty
  7  yes        Empty
  8  yes        Node(key=8)
  9  yes        Node(key=9)
 10  no         Empty

the right spine from the root : 5 8 9
```

Those three keys are exactly the ones `find` can retrieve. The private
recursive helper calls itself leftwards in sink context and discards the
result, so only the trailing rightward recursion propagates.

The method's own header comment promises a node "or 0 if not found", and it
returns `0` only for a completely empty tree. Otherwise it returns `Empty` — a
`Slip`, which is falsy and has zero elements — so `if $t.find($k) { … }`
silently reports "absent" for a key that is present.

There are three different not-found values and none of them is reliable. Use
`.keys.grep` for membership.

## Where the two engines differ

On non-numeric keys, and the difference is a crash against silent corruption.

`insert` picks a direction with numeric `>` and tests equality with string
`eq`, so the two never quite agree. With string keys, Raku++ throws `Cannot
convert string to number` on the first comparison. Rakudo returns a `Failure`
whose `.Bool` is `False`, so every comparison silently says "go right" and the
tree is built in an arbitrary shape **with no error at all** — the keys come
back unsorted and nothing reports it.

Numeric keys work correctly on both. Use numbers, or a numeric key with the
string as payload.
