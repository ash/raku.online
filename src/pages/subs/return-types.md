---
title: Return types
slug: return-types
status: full
order: 15
summary: Declare what a routine returns with --> in the signature.
---

A `-->` in the signature declares the routine's **return type**. The returned value
is type-checked against it, documenting the contract and catching a wrong-typed
return.

## Declaring a return type

`sub name(--> Type)` states the type with no parameters; it can also follow the
parameters.

```raku
sub answer(--> Int) {
    42;
}
say answer();
say answer().^name;
```
```output
42
Int
```

## With parameters

```raku
sub double($x --> Int) {
    $x * 2;
}
say double(21);
```
```output
42
```

## Notes

- `-->` is a *constraint*, not a coercion: returning a value of the wrong type is an
  error, it isn't silently converted. Use an explicit coercion in the body if needed.
- The return type also documents intent at the call site — tools and readers see the
  contract in the signature.
- `Nil`/`Failure` returns are always allowed regardless of the declared type, so
  `fail` still works in a typed routine.
