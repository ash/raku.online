---
title: State variables
slug: state
status: full
order: 70
summary: Per-closure persistent variables, initialised once and retained across calls.
---

A `state` variable lives inside a sub or block but keeps its value **between calls**.
Its initialiser runs only the first time execution reaches it; after that the stored
value persists.

## Persistent counter

```raku
sub counter {
    state $n = 0;
    return $n++;
}
say counter();
say counter();
say counter();
```
```output
0
1
2
```

`state $n = 0` initialises `$n` once; each call returns then increments the retained
value.

## Accumulating across calls

Because the initialiser is skipped after the first call, `state` is a clean way to
accumulate.

```raku
my &f = { state $x = 0; $x += $_ };
say f(10);
say f(5);
```
```output
10
15
```

## Notes

- `state` differs from `my`: a `my` variable is re-created (and re-initialised)
  every call, whereas a `state` variable is created once per closure and remembered.
- Each closure gets its own `state` storage — two clones of the same block do not
  share it, just as with [closures](/subs/closures/).
- The one-time initialiser makes `state $cache = expensive()` a tidy memoisation
  idiom.
