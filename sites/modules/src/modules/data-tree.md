---
name: Data::Tree
version: 0.3
auth: zef:stuart-little
kind: Distribution · data structures
summary: A Haskell-shaped rooted tree with builders, folds and two ASCII
  renderers — where `levels` returns nothing for a falsy root.
status: divergent
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:stuart-little/Data::Tree
source: https://github.com/stuart-little/raku-data-tree.git
---

## What it is for

Haskell's `Data.Tree` is a rose tree: a value plus a list of child trees, with
`unfoldTree` to build one from a seed and `foldTree` to reduce one. This
distribution is that shape in Raku, plus `lol2tree` for nested-array literals
and two renderers.

## Building and walking

```raku name="basics"
use Data::Tree;

my $t = lol2tree([1, [2, [4, 5]], [3, [6]]]);
say 'data     : ', $t.data;
say 'children : ', $t.children.map(*.data).join(', ');
say '';
say 'flatten  : ', flatten($t).raku;
say 'foldTree : ', foldTree(-> $d, @kids { $d + @kids.sum }, $t);
say '  (levels is engine-dependent — see the last section)';
say '';
print drawTree($t);
```

```output
data     : 1
children : 2, 3

flatten  : [1, 2, 4, 5, 3, 6]
foldTree : 21
  (levels is engine-dependent — see the last section)

1
|
+-2
| |
| `-4
|   |
|   `-5
|
`-3
  |
  `-6
```

```raku name="unfold"
use Data::Tree;

my $t = unfoldTree(-> $n { ($n, $n < 4 ?? ($n * 2, $n * 2 + 1) !! ()) }, 1);
say 'unfoldTree from 1, branching while n < 4:';
print drawTree($t);
say '';
say 'the two collections map and grep:';
say '  doubled : ', flatten($t.map(* * 10)).raku;
say '';
my $f = unfoldForest(-> $n { ($n, ()) }, [7, 8, 9]);
say 'a Forest of three singletons : ', $f.trees.map(*.data).join(', ');
print drawForest($f);
```

```output
unfoldTree from 1, branching while n < 4:
1
|
+-2
| |
| +-4
| |
| `-5
|
`-3
  |
  +-6
  |
  `-7
the two collections map and grep:
  doubled : [10, 20, 40, 50, 30, 60, 70]

a Forest of three singletons : 7, 8, 9
7

8

9
```

## The one thing to know

`levels` returns an **empty array** for any tree whose root data is falsy —
`0`, `''`, `False` — while `flatten` on the same tree returns everything.

```raku name="falsy-root"
use Data::Tree;

for 0, '', False, 'x' -> $root {
    my $t = lol2tree([$root, ['kid']]);
    say sprintf('  root %-14s flatten %-22s levels %s',
                $root.raku, flatten($t).raku, levels($t).raku);
}
say '';
say 'the guard is  (! $t.data) && return [];  — so a tree of counters or';
say 'flags rooted at 0 silently has no levels.';
say '';
say 'build your own if the root can be falsy:';
sub tiers($t) {
    my @out;
    my @cur = ($t,);
    while @cur { @out.push([@cur.map(*.data)]); @cur = @cur.map({ |$_.children }).Array }
    @out
}
say '  tiers on a 0-rooted tree : ', tiers(lol2tree([0, ['kid']])).raku;
```

```output
  root 0              flatten [0, "kid"]             levels []
  root ""             flatten ["", "kid"]            levels []
  root Bool::False    flatten [Bool::False, "kid"]   levels []
  root "x"            flatten ["x", "kid"]           levels [["x"], ["kid"]]

the guard is  (! $t.data) && return [];  — so a tree of counters or
flags rooted at 0 silently has no levels.

build your own if the root can be falsy:
  tiers on a 0-rooted tree : [[0], ["kid"]]
```

## The names are not what you type

```raku name="names"
use Data::Tree;

say 'the file says `unit module Tree;`, so:';
say '  RTree.^name  : ', RTree.^name;
say '  Forest.^name : ', Forest.^name;
say '';
say '  ::("Data::Tree::RTree").defined : ', ::('Data::Tree::RTree').defined;
say '  ::("Tree::RTree").defined       : ', ::('Tree::RTree').defined;
say '';
say 'the short names are exported, so you rarely need either — but a';
say 'fully qualified reference has to use Tree::, not Data::Tree::.';
say '';
say 'and the grep predicate takes the NODE, not the data:';
say '  $t.grep(* > 2)             dies';
say '  $t.grep({ .data > 2 })     is what you want';
```

```output
the file says `unit module Tree;`, so:
  RTree.^name  : Tree::RTree
  Forest.^name : Tree::Forest

  ::("Data::Tree::RTree").defined : False
  ::("Tree::RTree").defined       : False

the short names are exported, so you rarely need either — but a
fully qualified reference has to use Tree::, not Data::Tree::.

and the grep predicate takes the NODE, not the data:
  $t.grep(* > 2)             dies
  $t.grep({ .data > 2 })     is what you want
```

## Where the two engines differ

Two. `levels` returns one node per level under Raku++ — `roundrobin` flattens
its list arguments one level too deep there. And `.grep` on an `RTree` or
`Forest` is broken under Raku++ entirely, because the real implementation is a
file-scoped `my multi method grep` reached through `self.&grep(&f)`, which
resolves to the built-in `Any.grep` instead.

```raku name="portable"
use Data::Tree;

my $t = lol2tree([1, [2, [4, 5]], [3, [6]]]);
say 'flatten is identical on both engines : ', flatten($t).raku;
say 'foldTree likewise                    : ',
    foldTree(-> $d, @k { $d + @k.sum }, $t);
say 'drawTree likewise.';
say '';
say 'levels and grep are not. Write them yourself:';
sub tiers($t) {
    my @out; my @cur = ($t,);
    while @cur { @out.push([@cur.map(*.data)]); @cur = @cur.map({ |$_.children }).Array }
    @out
}
sub prune($t, &keep) {
    return Nil unless keep($t);
    RTree.new(data => $t.data, children => $t.children.map({ prune($_, &keep) }).grep(*.defined))
}
say '  tiers : ', tiers($t).raku;
say '  prune : ', flatten(prune($t, { .data != 2 })).raku;
```

```output
flatten is identical on both engines : [1, 2, 4, 5, 3, 6]
foldTree likewise                    : 21
drawTree likewise.

levels and grep are not. Write them yourself:
  tiers : [[1], [2, 3], [4, 6], [5]]
  prune : [1, 3, 6]
```
