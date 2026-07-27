---
title: Junctions
chapter: Beyond
summary: any, all and | let one value be several values at once — and comparisons distribute over them.
---

A junction is a single value that is *several values at once*. Compare
against it and the comparison distributes:

```raku
my $roll = 5;
if $roll == 1 | 3 | 5 {
    say 'odd roll';
}
say so 7 == any(2, 4, 7);
```
```output
odd roll
True
```

`1 | 3 | 5` and `any(2, 4, 7)` are the same idea — no need to write three
comparisons and chain them with or.

## all, any, one, none

Each collapses to True under a different condition:

```raku
my @scores = 62, 75, 88;
say so all(@scores) >= 50;
say so any(@scores) > 80;
say so one(@scores) < 70;
say so none(@scores) == 100;
```
```output
True
True
True
True
```

Read them aloud and they're already documentation: *all scores at least 50;
some score above 80; exactly one below 70; none equal to 100.*

## Junctions travel through calls

Pass a junction to a function and the function runs for each member:

```raku
sub double($n) { $n * 2 }
say so double(any(2, 3)) == 6;
```
```output
True
```

## Try it

Using `all`, check whether every word in the list is shorter than 8
characters.

```raku exercise
my @words = <grammar junction whatever>;
```

```solution
my @words = <grammar junction whatever>;
say so all(@words).chars < 8;
```
```output
False
```
