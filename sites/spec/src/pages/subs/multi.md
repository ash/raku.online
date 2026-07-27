---
title: Multi dispatch
slug: multi
status: full
order: 40
summary: Several sub variants under one name; the best-fitting signature is chosen per call.
---

A `multi sub` declares one of several **candidates** sharing a name. At each call,
Raku picks the candidate whose signature best fits the arguments — dispatching on
their types, counts, and values.

## Dispatch by type

```raku
multi describe(Int $n) {
    "int $n";
}
multi describe(Str $s) {
    "str $s";
}
say describe(42);
say describe("hi");
```
```output
int 42
str hi
```

The `42` matches the `Int` candidate, `"hi"` the `Str` one — chosen by the
arguments' types, with no manual type-checking in the body.

## Dispatch by arity

Candidates can differ purely in how *many* parameters they take; the call's argument
count picks one.

```raku
multi greet()   { "hello" }
multi greet($n) { "hi $n" }
say greet();
say greet("Sam");
```
```output
hello
hi Sam
```

## Dispatch by value and where

A candidate can match a literal value or a `where` predicate, which is how a recursive
definition names its base case separately from the general one.

```raku
multi fac(0)                        { 1 }
multi fac(Int $n where * > 0)       { $n * fac($n - 1) }
say fac(5);
```
```output
120
```

The call `fac(0)` matches the literal-`0` candidate; every positive `Int` matches the
`where` candidate, which recurses down to it.

## Notes

- Candidates can differ by arity (number of parameters), parameter types, or even
  literal values and `where` constraints — a candidate for `0` and a general one,
  say.
- When two candidates fit, the **narrower** (more specific) one wins; a genuine tie
  is an "ambiguous dispatch" error.
- If no candidate matches, that is a run-time error listing the candidates tried —
  the usual signal you need one more `multi`.
- Ordinary `sub` and `multi sub` don't mix under the same name; pick one style per
  name.
