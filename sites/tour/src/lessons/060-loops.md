---
title: Loops
chapter: Control flow
summary: Iterate with for over ranges, ^N, and pointy blocks; while, last, and next round it out.
---

`for` iterates over anything listy. A range like `1..5` counts inclusively;
the pointy block `-> $i` names the current element:

```raku
for 1..3 -> $i {
    say "bottle $i";
}
```
```output
bottle 1
bottle 2
bottle 3
```

Without a pointy block, the current element lands in the *topic* variable `$_`:

```raku
for <lint test ship> {
    say "step: $_";
}
```
```output
step: lint
step: test
step: ship
```

## ^N — the first N numbers

`^5` is the range `0..4` — "up to but not including 5". You'll see it
everywhere:

```raku
say "hello #$_" for ^3;
```
```output
hello #0
hello #1
hello #2
```

That's the statement-modifier form of `for`, this time with nothing to set up.

## while, last, next

`while` loops on a condition; `last` breaks out of a loop and `next` skips to
the next iteration:

```raku
my $n = 1;
while $n < 100 {
    $n *= 3;
}
say $n;

for 1..10 {
    next if $_ %% 2;
    last if $_ > 7;
    say $_;
}
```
```output
243
1
3
5
7
```

## Try it

Print the multiplication table row for 7 — from `7 x 1 = 7` to `7 x 5 = 35`.

```raku exercise
for 1..5 -> $i {
}
```

```solution
for 1..5 -> $i {
    say "7 x $i = { 7 * $i }";
}
```
```output
7 x 1 = 7
7 x 2 = 14
7 x 3 = 21
7 x 4 = 28
7 x 5 = 35
```
