---
name: LCS::All
version: 0.2.0
auth: none stated
kind: Distribution · algorithms
summary: Every longest common subsequence of two sequences, not just one,
  returned as lists of index pairs into the originals.
status: full
suite: 1 file, green
tested: 2026-09-15
license: none stated
depends: none beyond the core
raku-land: https://raku.land/?/LCS::All
source: git://github.com/wollmers/P6-LCS-All.git
---

## What it is for

A normal longest-common-subsequence routine picks one winner among ties. For a
diff tool that is a problem: when two alignments are equally good, showing the
user an arbitrary one produces the diffs people complain about — the ones
where a moved block is rendered as an unrelated delete and insert.

This distribution enumerates **all** of them, so a caller can choose.

## Every alignment

```raku name="all"
use LCS::All;

sub show(@a, @b) {
    my @r = allLCS(@a, @b);
    say sprintf('%-18s %-18s', @a.join(''), @b.join(''));
    for @r[0].list -> $solution {
        say '  solution : ',
            $solution.elems
              ?? $solution.map({ "({.[0]},{.[1]})" }).join(' ')
              !! '(none)';
    }
}

show [<a b c>], [<a b c>];
show [<a b c>], [<a c b>];
show [<a b c d>], [<b d>];
show [<a b>], [<c d>];
```

```output
abc                abc               
  solution : (0,0) (1,1) (2,2)
abc                acb               
  solution : (0,0) (1,2)
  solution : (0,0) (2,1)
abcd               bd                
  solution : (1,0) (3,1)
ab                 cd                
  solution : (none)
```

`abc` against `acb` genuinely has two distinct longest common subsequences of
length two — `a,c` and `a,b` — and both are listed. That is the case a
single-answer routine has to pick between.

## Recovering the elements

```raku name="recover"
use LCS::All;

my @x = <t h e   q u i c k>.grep(*.chars);
my @y = <t h e   q u a c k>.grep(*.chars);

my @r = allLCS(@x, @y);
say 'solutions : ', @r[0].elems;
for @r[0].list -> $s {
    say '  as indices  : ', $s.map({ "({.[0]},{.[1]})" }).join(' ');
    say '  as elements : ', $s.map({ @x[.[0]] }).join('');
}
```

```output
solutions : 1
  as indices  : (0,0) (1,1) (2,2) (3,3) (4,4) (6,6) (7,7)
  as elements : thequck
```

You get **index pairs**, not elements. To recover the subsequence you map the
first index of each pair back through your own array — which is more work than
returning the elements, and is the right choice, because the indices are what
a diff actually needs.

## The one thing to know

The result is wrapped three levels deep, and the "no common subsequence"
answer is not empty.

```raku name="depth-trap"
use LCS::All;

my @disjoint = allLCS([<a b>], [<c d>]);

say 'allLCS on two disjoint sequences:';
say '  the whole return value : ', @disjoint.raku;
say '  .elems                 : ', @disjoint.elems;
say '  is it true?            : ', ?@disjoint;
say '';
say 'the genuinely empty thing is three subscripts down:';
say '  [0].elems     : ', @disjoint[0].elems;
say '  [0][0].elems  : ', @disjoint[0][0].elems;
say '';
say 'so this test is always true and tells you nothing:';
say '  if allLCS(...) { ... }   ->  ', ?allLCS([<a b>], [<c d>]);
say 'and this is the one that works:';
say '  allLCS(...)[0][0].elems  ->  ', allLCS([<a b>], [<c d>])[0][0].elems;
```

```output
allLCS on two disjoint sequences:
  the whole return value : [[[],],]
  .elems                 : 1
  is it true?            : True

the genuinely empty thing is three subscripts down:
  [0].elems     : 1
  [0][0].elems  : 0

so this test is always true and tells you nothing:
  if allLCS(...) { ... }   ->  True
and this is the one that works:
  allLCS(...)[0][0].elems  ->  1
```

The structure is an outer one-element list, then the list of solutions, then
each solution as a list of `[i, j]` pairs. `allLCS($x, $y).elems` is `1`
whether there are two solutions or none, and the value is truthy either way.

Test `@r[0][0].elems`, or `@r[0].grep(*.elems)`.

## Where the two engines differ

Nowhere. Every alignment, including all four degenerate pairs, produced
byte-identical output on Raku++ and Rakudo, and no input raised an exception.

The distribution states **neither an author nor a licence** in its metadata,
which matters if the result is going into anything you redistribute.
