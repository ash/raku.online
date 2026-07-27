---
title: Subroutines
chapter: Functions
summary: Declare subs with typed, optional, and named parameters; the last expression is the return value.
---

`sub` declares a function. Parameters go in the signature; the last evaluated
expression is returned automatically (an explicit `return` also works):

```raku
sub greet($name) {
    "Hello, $name!"
}
say greet('Ada');
say greet('Grace');
```
```output
Hello, Ada!
Hello, Grace!
```

## Defaults and named parameters

A parameter can have a default. Prefix one with `:` and it becomes *named* —
callers pass it by name, in any order:

```raku
sub power($base, :$exp = 2) {
    $base ** $exp
}
say power(5);
say power(2, exp => 10);
```
```output
25
1024
```

## Types

Add a type to a parameter and Raku enforces it. This signature also shows a
*return type* after the arrow:

```raku
sub double(Int $n --> Int) {
    $n * 2
}
say double(21);
```
```output
42
```

Call it as `double('fish')` and you get a type error instead of a silent
mistake — try it.

## Try it

Write `max2($a, $b)` returning the larger of the two (the ternary `?? !!`
from lesson 5 is perfect here).

```raku exercise
sub max2($a, $b) {
}
say max2(3, 8);
say max2(9, 4);
```

```solution
sub max2($a, $b) {
    $a > $b ?? $a !! $b
}
say max2(3, 8);
say max2(9, 4);
```
```output
8
9
```
