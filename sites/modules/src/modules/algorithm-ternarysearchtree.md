---
name: Algorithm::TernarySearchTree
version: 0.0.5
auth: zef:titsuki
kind: Distribution · data structures
summary: A ternary search tree over whole strings — one character per level,
  a binary search among the alternatives — with exact lookup and a
  fixed-length wildcard match.
status: full
suite: 4 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:titsuki/Algorithm::TernarySearchTree
source: https://github.com/titsuki/raku-Algorithm-TernarySearchTree.git
---

## What it is for

A hash answers "is this string in the set" and nothing else. A trie answers
that plus every prefix query, at the cost of one node per character per
distinct branch. A ternary search tree sits between them: each node splits on
one character with lower, equal and higher children, so it walks one character
per "equal" step and binary-searches the alternatives at each position.

That makes it the right structure when the set is large, the alphabet is wide,
and you want pattern queries as well as membership.

## Storing and finding

```raku name="tst"
use Algorithm::TernarySearchTree;

my $t = Algorithm::TernarySearchTree.new;
$t.insert($_) for <cat cats car card care dog do doge>;

for <cat cats ca card do dog doge dogs x> -> $k {
    say sprintf('contains(%-6s) = %s', "'$k'", $t.contains($k));
}
```

```output
contains('cat' ) = True
contains('cats') = True
contains('ca'  ) = False
contains('card') = True
contains('do'  ) = True
contains('dog' ) = True
contains('doge') = True
contains('dogs') = False
contains('x'   ) = False
```

Note `do` and `dog` are both present and both found. Every key is stored with
a trailing sentinel character, which is what lets a stored key that is a prefix
of another stored key still be retrievable.

## The wildcard match

```raku name="partial"
use Algorithm::TernarySearchTree;

my $t = Algorithm::TernarySearchTree.new;
$t.insert($_) for <cat cats car card care dog do doge>;

for 'ca.', 'c..', '...', 'do.', 'do', 'cat', 'ca.s', '....' -> $p {
    say sprintf('partial-match(%-6s) -> {%s}', "'$p'",
        $t.partial-match($p).keys.sort.join(' '));
}
say '';
say 'return type : ', $t.partial-match('ca.').^name;
```

```output
partial-match('ca.' ) -> {car cat}
partial-match('c..' ) -> {car cat}
partial-match('...' ) -> {car cat dog}
partial-match('do.' ) -> {dog}
partial-match('do'  ) -> {do}
partial-match('cat' ) -> {cat}
partial-match('ca.s') -> {cats}
partial-match('....') -> {card care cats doge}

return type : Set
```

`.` matches exactly one character. The result is a `Set`, so it is unordered
and deduplicated — sort the keys for anything you will print.

## The one thing to know

`partial-match` matches a **fixed length**, not a prefix. `'...'` returns only
the three-character keys; there is no pattern that returns both `do` and
`dog`.

```raku name="fixed-length"
use Algorithm::TernarySearchTree;

my $t = Algorithm::TernarySearchTree.new;
$t.insert($_) for <do dog doge dogs>;

for 'do', 'do.', 'do..', 'd...' -> $p {
    say sprintf('%-7s -> {%s}', "'$p'", $t.partial-match($p).keys.sort.join(' '));
}
say '';
say 'there is no single pattern that returns all four:';
say '  you must ask per length, or keep your own prefix index';
for 2 .. 4 -> $n {
    say sprintf('  length %d : {%s}', $n,
        $t.partial-match('.' x $n).keys.sort.join(' '));
}
```

```output
'do'    -> {do}
'do.'   -> {dog}
'do..'  -> {doge dogs}
'd...'  -> {doge dogs}

there is no single pattern that returns all four:
  you must ask per length, or keep your own prefix index
  length 2 : {do}
  length 3 : {dog}
  length 4 : {doge dogs}
```

A pattern with no wildcard behaves like an exact match, which makes the
constraint easy to miss until a prefix query silently returns `set()`. There
is no `starts-with`, no key enumeration, no delete and no associated value —
this is a set of strings, and walking it means guessing lengths.

A second thing in the same spirit: `.` is an **unescapable** wildcard. A key
that actually contains a dot can be found by `contains` but cannot be
distinguished by `partial-match`, which will return every key of that length
matching in the other positions.

## Where the two engines differ

Nowhere. Correctness was cross-checked over all 39 strings of length one to
three over a three-letter alphabet, in four different insertion orders, with
every single-wildcard three-character pattern — zero failures on either
engine, and identical output throughout.

The thing to size before you use it is the shape of the tree, because there is
**no balancing anywhere**. Inserting keys in sorted order collapses the binary
dimension into a linked list, so the "search tree" becomes a linear scan of
the alternatives at every character position:

```raku name="balance"
use Algorithm::TernarySearchTree;
use Algorithm::TernarySearchTree::Node;

sub depth($n) { return 0 unless $n.defined; 1 + max(depth($n.lokid), depth($n.eqkid), depth($n.hikid)) }
sub chain($n) {
    return 0 unless $n.defined;
    max(1 + chain($n.lokid), 1 + chain($n.hikid), chain($n.eqkid))
}

my @letters = 'a' .. 'z';
for 'sorted', @letters.map(* ~ 'x'),
    'reversed', @letters.reverse.map(* ~ 'x'),
    'middle-out', (@letters[13 .. *], @letters[^13].reverse).flat.map(* ~ 'x')
-> $how, @keys {
    my $t = Algorithm::TernarySearchTree.new;
    $t.insert($_) for @keys;
    say sprintf('%-11s 26 keys -> depth %2d, longest lo/hi chain %2d',
        $how, depth($t.root), chain($t.root));
}
```

```output
sorted      26 keys -> depth 28, longest lo/hi chain 26
reversed    26 keys -> depth 28, longest lo/hi chain 26
middle-out  26 keys -> depth 16, longest lo/hi chain 14
```

Sorted input is the common case — dictionaries, word lists, anything that came
out of a `.sort` — and it is precisely the input that gives worst-case
behaviour. Shuffle before building, or insert middle-out.

`.root` also hands out the live `Node`, whose `lokid`, `eqkid` and `hikid` are
`is rw`, so a caller can corrupt the structure through it.
