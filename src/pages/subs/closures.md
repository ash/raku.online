---
title: Closures
slug: closures
status: full
order: 60
summary: Blocks that capture the lexical variables in scope where they were created.
---

A **closure** is a block or sub that captures the variables in scope where it was
defined and keeps them alive. Each time the enclosing scope runs, a fresh set of
captured variables is made — so closures created separately don't share state.

## Capturing a variable

The returned block below keeps `$n` alive after `make-counter` has returned, and
mutates it on each call.

```raku
sub make-counter {
    my $n = 0;
    return { $n++ };
}
my $c = make-counter();
say $c();
say $c();
say $c();
```
```output
0
1
2
```

## Independent captures

Every call to `make-counter` creates a new `$n`, so two counters are independent.

```raku
sub make-counter { my $n = 0; return { $n++ } }
my $a = make-counter();
my $b = make-counter();
say $a();
say $a();
say $b();
```
```output
0
1
0
```

`$a` advances to `1`, but `$b` starts fresh at `0` — each closure has its own `$n`.

## Notes

- Closures are the basis of Raku's higher-order style: the block passed to `map`,
  `grep`, or `sort` closes over its surrounding variables.
- The capture is by *reference* to the container, not a copy of the value — that is
  why `$n++` inside the block is visible on the next call.
- To keep per-call state *inside* a single sub rather than a returned closure, use a
  [state variable](/subs/state/).
