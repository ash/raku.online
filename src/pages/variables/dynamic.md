---
title: Dynamic variables  $*
slug: dynamic
status: full
order: 50
summary: Variables looked up through the call stack, not the lexical scope.
---

A variable with the `*` twigil (`$*name`) is **dynamic**: a called routine sees the
caller's value, not one from where the routine was written. It's controlled action at
a distance — for context like the current output handle or a request-scoped setting.

## Visible down the call stack

```raku
my $*greeting = "hi";
sub greet { say $*greeting }
greet();
```
```output
hi
```

`greet` never declares `$*greeting`, yet finds it — because the lookup walks the
*dynamic* (caller) chain, not the lexical scope.

## Rebinding for an inner scope

Because the lookup follows the caller, redefining a dynamic variable in an inner block
changes what calls *made from that block* see — and only those. When the block ends,
the outer binding is back.

```raku
my $*g = "outer";
sub greet { say $*g }
{
    my $*g = "inner";
    greet();
}
greet();
```
```output
inner
outer
```

The first `greet()` runs while the inner `$*g` is in effect, so it prints `inner`; the
second runs after the block, seeing `outer` again. (For an automatic restore without a
new lexical scope, use [`temp`](/variables/temp/).)

## Notes

- Contrast with a `my` variable, which a sub only sees if it's in the sub's lexical
  scope; a dynamic variable is found via whoever called, however deep.
- The built-ins use this: `$*OUT` (standard output), `$*IN`, `$*ERR`, `$*PID`, and
  `$*CWD` are dynamic, so you can temporarily rebind `$*OUT` to capture output.
- Rebinding in an inner scope (`{ my $*greeting = "yo"; greet() }`) affects only calls
  made from within that scope — the change is dynamically scoped.
