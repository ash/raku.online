---
title: BEGIN & END
slug: compile-run
status: full
order: 10
summary: Run code at compile time (BEGIN) or at program exit (END).
---

A **phaser** is a block that runs at a particular moment in a program's life, not
where it is written. `BEGIN` fires at compile time — as soon as it is parsed — and
`END` fires once, as the program shuts down.

## BEGIN — at compile time

`BEGIN` runs during compilation, before any run-time code, so its output appears
first regardless of position.

```raku
BEGIN say "compile-time";
say "run-time";
```
```output
compile-time
run-time
```

## BEGIN as a value

`BEGIN` also produces a value, computed once at compile time and frozen into the
program — useful for constants.

```raku
my $t = BEGIN { 2 * 21 };
say $t;
```
```output
42
```

## END — at exit

`END` runs when the program finishes, after the main body — even if the `END` block
is written first.

```raku
say "body";
END say "at exit";
```
```output
body
at exit
```

## Notes

- Because `BEGIN` runs at compile time, anything it references must already be
  available then; it is the mechanism behind `constant` and compile-time `use`
  effects.
- Multiple `END` blocks run in reverse order of definition (last defined, first
  run), like a stack of cleanups.
- `INIT` is the run-time cousin of `BEGIN`: it runs once, at the start of execution
  rather than during compilation.
