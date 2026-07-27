---
title: fail & Failure
slug: fail
status: full
order: 60
summary: Return a soft, unthrown error — a Failure — instead of dying immediately.
---

`fail` is the gentle sibling of `die`. Instead of throwing, it **returns** a
`Failure` — a lazy, unthrown exception. The caller can inspect it calmly; the error
only becomes fatal if the Failure is used as a real value.

## Returning a Failure

```raku
sub f { fail "nope" }
my $r = f();
say $r.defined;
say $r.exception.message;
```
```output
False
nope
```

`f()` returns rather than throwing, so `$r` is a defined-`False` Failure whose
`.exception` carries the original message.

## Consuming a Failure

A caller that *checks* proceeds calmly. `try` catches the re-thrown exception so `//`
can supply a default, and `with`/`else` branches on the Failure being undefined.

```raku
sub parse($s) { $s ~~ /^ \d+ $/ ?? +$s !! fail "not a number" }
say (try parse("x")) // -1;
say parse("42");
with parse("nope") -> $v { say "ok $v" } else { say "handled" }
```
```output
-1
42
handled
```

`parse("x")` fails, so `try …  // -1` yields the default; `parse("42")` returns the
number normally; and the `with` block takes its `else` branch because the Failure is
undefined.

## Notes

- A `Failure` is "unthrown": checking it (`.defined`, `so $r`) is safe and returns
  false, but using it in a context that needs a real value re-throws the exception.
- This makes `fail` ideal for routines that report problems as return values —
  callers that check succeed quietly, callers that ignore the check get a normal
  exception.
- `try { f() } // default` and `with f() { … } else { … }` are the idiomatic ways to
  consume a possibly-failing routine.
