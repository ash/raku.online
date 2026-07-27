---
title: Typed exceptions
slug: typed-exceptions
status: full
order: 50
summary: Define your own Exception subclasses and dispatch on them in CATCH.
---

Exceptions are objects. Subclassing `Exception` gives you a named error type you can
throw and then match precisely in a `CATCH` block — cleaner than inspecting message
strings.

## A custom exception

Give the subclass a `message` method (its human-readable text) and throw an instance
with `.throw`. `CATCH` then matches it by type with `when`.

```raku
class MyErr is Exception {
    method message { "custom error" }
}
try {
    MyErr.new.throw;
    CATCH {
        when MyErr { say "got MyErr" }
    }
}
```
```output
got MyErr
```

## Matching by pattern

Because `CATCH` uses smartmatch, you can also branch on the message with a regex,
falling back to `default`.

```raku
try {
    die "specific";
    CATCH {
        when /specific/ { say "matched pattern" }
        default { say "other" }
    }
}
```
```output
matched pattern
```

## Notes

- `when SomeType` works because smartmatch against a type tests membership; add
  attributes to the exception class to carry structured data alongside the message.
- List several `when` clauses to handle different exception types distinctly, with a
  final `default` for the rest.
- Built-in errors are already typed (`X::TypeCheck`, `X::AdHoc`, …), so real handlers
  can catch, say, only `X::IO` and let everything else propagate.
