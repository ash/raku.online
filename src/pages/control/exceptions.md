---
title: die / try / CATCH
slug: exceptions
status: full
order: 40
summary: Throw with die, contain with try, and handle with a CATCH block.
---

`die` throws an exception, unwinding the call stack until something handles it. A
`try` block contains that unwinding, and a `CATCH` block inside it decides what to
do with whatever was thrown.

## Throwing and catching

`CATCH` sits inside the block whose exceptions it handles. Its `default` clause
catches anything; the caught exception is the topic `$_`, with `.message` its text.

```raku
try {
    die "boom";
    CATCH {
        default { say "caught: ", .message }
    }
}
```
```output
caught: boom
```

## try as an expression

A `try` block with no `CATCH` swallows the exception and evaluates to `Nil`, and
sets the error variable `$!`. Combined with `//` it gives a tidy fallback.

```raku
sub risky($x) {
    die "negative" if $x < 0;
    return $x * 2;
}
say risky(5);
say try { risky(-1) } // "failed";
```
```output
10
failed
```

After a swallowed failure, `$!` holds the exception:

```raku
my $r = try { die "x" };
say $r.defined;
say $!.message;
```
```output
False
x
```

## Notes

- `CATCH` matches with `when`/`default` (smartmatch), so you can branch on exception
  type or message — see [Typed exceptions](/control/typed-exceptions/).
- A `CATCH` that handles the exception lets the enclosing block **continue** past it,
  rather than propagating — the basis of resumable, per-iteration recovery.
- `die` with a non-string argument throws that object directly; `die` with a string
  wraps it in an `X::AdHoc` exception whose `.message` is that string.
