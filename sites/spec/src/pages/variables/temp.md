---
title: temp — save and restore a variable
slug: temp
status: full
order: 55
summary: Temporarily change a variable and have it restored automatically at scope exit.
---

`temp` remembers a variable's value on entry to the current scope and **restores it
automatically when the scope ends** — no matter how it ends. It's the clean way to
make a temporary change to an outer or dynamic variable without manually saving and
resetting it, which is easy to get wrong when a block can exit early.

## The basic pattern

`temp $x = …` sets a new value for the rest of the block; once the block returns, the
old value is back.

```raku
my $x = "outer";
sub f { temp $x = "inner"; g() }
sub g { say $x }
f();
say $x;
```
```output
inner
outer
```

While `f` runs, `$x` is `"inner"` (so `g` sees it); after `f` returns, `$x` is
`"outer"` again. `temp $x` on its own (no `=`) keeps the current value but still marks
it for restoration, so later assignments inside the block are undone on exit.

## Restoring a dynamic variable across recursion

`temp` shines with [dynamic variables](/variables/dynamic/): each recursive call
can bump a shared `$*` variable and have its own change unwound as it returns, so the
value tracks the call depth exactly.

```raku
my $*LEVEL = 0;
sub deeper {
    temp $*LEVEL = $*LEVEL + 1;
    say "at $*LEVEL";
    deeper() if $*LEVEL < 3;
}
deeper();
say "back to $*LEVEL";
```
```output
at 1
at 2
at 3
back to 0
```

## Container elements too

`temp` works on a single array or hash element, restoring just that slot.

```raku
my @a = 1, 2, 3;
sub tweak { temp @a[1] = 99; say @a }
tweak();
say @a;
```
```output
[1 99 3]
[1 2 3]
```

## Notes

- Restoration happens on *any* scope exit — normal return, `last`/`next`, or an
  exception unwinding through it — which is what makes `temp` safer than a manual
  save/restore pair.
- `temp` restores the *value*, not the container: `temp @a` saves and restores the
  whole array's contents.
- The related `let` restores its variable only when the block exits with a **failure**
  (a false or failed value), for speculative changes you want to keep on success and
  undo on failure.
- Because `temp` is tied to the lexical scope, put it in the narrowest block whose exit
  should trigger the restore.
