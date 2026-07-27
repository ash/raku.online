---
title: if / unless / with
slug: conditionals
status: full
order: 10
summary: Boolean branching with if/elsif/else and unless; definedness branching with with.
---

Conditionals choose a block to run. `if` branches on truth, `unless` on its
negation, and `with` on *definedness* (rather than truth), topicalising the tested
value.

## if / elsif / else

```raku
my $n = 7;
if $n > 5 {
    say "big";
}
elsif $n > 0 {
    say "small";
}
else {
    say "non-positive";
}
```
```output
big
```

## unless

`unless` runs its block when the condition is false. It takes no `else` — reach for
`if` when you need both branches.

```raku
my $x = 0;
unless $x {
    say "falsy";
}
say "ok" if $x == 0;
```
```output
falsy
ok
```

## with / without

`with` runs when its argument is **defined** (not just true) and sets `$_` to it;
`without` is the complement. This is the clean way to handle "maybe a value".

```raku
my $v = 42;
with $v {
    say "defined: $_";
}
without Any {
    say "no value";
}
```
```output
defined: 42
no value
```

## Notes

- All of these are expressions in statement position; for a value-returning choice
  inside an expression use the [ternary](/operators/ternary/) `?? !!`.
- The postfix forms — `say $x if $cond`, `... unless ...`, `... with ...` — read
  well for one-line guards.
- `with 0 { }` **runs**: `0` is defined even though it is false. That is the whole
  point of `with` versus `if`.
