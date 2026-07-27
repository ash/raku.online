---
title: The match & error variables  $/ and $!
slug: match-error
status: full
order: 40
summary: Two special variables Raku sets for you — the last regex match and the last error.
---

Two special lexical variables are populated automatically: `$/` holds the most
recent regex match, and `$!` holds the most recently caught exception. The capture
shortcuts and error handling both read from them.

## $/ — the match

A successful `~~` against a regex sets `$/`. The positional captures `$0`, `$1`, …
are shortcuts into it (`$0` is `$/[0]`).

```raku
"abc123def" ~~ /(\d+)/;
say ~$/;
say ~$0;
```
```output
123
123
```

## $! — the error

Inside (or after) a failed `try`, `$!` holds the exception, whose `.message` is its
text.

```raku
try { die "oops" }
say $!.message;
```
```output
oops
```

## Notes

- `$/` is why `$0`/`$<name>` work anywhere after a match — they don't need to be in
  the `if` that did the matching, just in the same scope.
- Both are ordinary lexicals, so their value is scoped to the current routine/block;
  a nested match sets its own `$/`.
- After a *successful* `try`, `$!` is reset to an undefined value, so
  `$!.defined` is a clean "did the last try fail?" test.
