---
title: Defining subroutines
slug: defining
status: full
order: 10
summary: sub declarations, the parameter signature, and how a value gets returned.
---

A subroutine is declared with `sub`, a name, a **signature** in parentheses, and a
body. Calling it binds the arguments to the signature's parameters.

## A basic sub

```raku
sub greet($name) {
    "Hello, $name!";
}
say greet("Ada");
```
```output
Hello, Ada!
```

## Returning a value

The value of the **last expression** is returned automatically — no `return`
needed. Use an explicit `return` to leave early.

```raku
sub square($x) {
    $x ** 2;
}
say square(9);
```
```output
81
```

`return` stops the sub immediately; anything after it does not run:

```raku
sub double($x) {
    return $x * 2;
    say "never reached";
}
say double(5);
```
```output
10
```

## Notes

- The signature `($name)` declares one required positional parameter. Parameters
  are read-only by default — assigning to `$name` inside the sub is an error unless
  it is declared `is rw` or `is copy`.
- A sub with an empty signature, `sub f() { … }`, takes no arguments; calling it
  with any is an error.
- Subs are lexically scoped by default and can be nested inside other subs or
  blocks.
