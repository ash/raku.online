---
title: Multiple dispatch
chapter: Functions
summary: Declare several multi subs with one name; Raku picks the right one by the arguments.
---

Declare several subs with the same name using `multi`, and Raku chooses among
them by the arguments' types:

```raku
multi describe(Int $n) { "an integer: $n" }
multi describe(Str $s) { "a string: $s" }
say describe(42);
say describe('camelia');
```
```output
an integer: 42
a string: camelia
```

## Dispatch on values

A parameter can be a literal *value*, which turns recursion base cases into
their own candidates — no `if` in sight:

```raku
multi fact(0) { 1 }
multi fact(Int $n where * > 0) { $n * fact($n - 1) }
say fact(5);
say fact(20);
```
```output
120
2432902008176640000
```

The `where * > 0` is a *constraint*: that candidate only matches positive
integers. (The `*` builds a small anonymous function — "the thing being
tested, greater than zero". More of it in the next lesson.)

## Constraints do the branching

```raku
multi bottles(0) { 'no more bottles' }
multi bottles(1) { '1 bottle' }
multi bottles($n) { "$n bottles" }
say bottles($_) for 2, 1, 0;
```
```output
2 bottles
1 bottle
no more bottles
```

## Try it

Write the Fibonacci function with three multis: `fib(0)` is 0, `fib(1)` is 1,
and everything else is the sum of the two before it.

```raku exercise
multi fib(0) { 0 }

say fib(10);
```

```solution
multi fib(0) { 0 }
multi fib(1) { 1 }
multi fib(Int $n) { fib($n - 1) + fib($n - 2) }
say fib(10);
```
```output
55
```
