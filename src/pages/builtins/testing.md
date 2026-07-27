---
title: Testing — use Test
slug: testing
status: full
order: 75
summary: The built-in Test module — plan, ok, is, isnt, is-deeply — emitting TAP.
---

`use Test` brings in Raku's standard testing routines. Each assertion prints a **TAP**
line (`ok N - description` or `not ok N …`), and `plan` declares how many you expect.
This is the same module Raku's own test suite uses, and it runs unchanged in the
playground.

## A small test suite

`plan` states the count; `ok` asserts a truthy value; `is` checks a value against an
expected one; `isnt` checks inequality.

```raku
use Test;
plan 3;
ok 2 > 1, "two is greater than one";
is "ab".uc, "AB", "uppercasing";
isnt "cat", "dog", "different words";
```
```output
1..3
ok 1 - two is greater than one
ok 2 - uppercasing
ok 3 - different words
```

Each passing assertion is numbered in order, and the `1..3` plan line lets a test
harness confirm the whole suite ran.

## Comparing structures — is-deeply

`is` compares stringified values; `is-deeply` compares structure and type exactly, so
it's the right check for lists, hashes, and nested data.

```raku
use Test;
plan 2;
is-deeply (1, 2, 3).grep(* > 1).List, (2, 3), "grep keeps the tail";
is-deeply { a => 1, b => 2 }, { b => 2, a => 1 }, "hash order-independent";
```
```output
1..2
ok 1 - grep keeps the tail
ok 2 - hash order-independent
```

## Notes

- Core assertions: `ok`/`nok` (truthy/falsy), `is`/`isnt` (string-equal or not),
  `is-deeply` (structural), `like`/`unlike` (regex match), `cmp-ok` (compare with a
  named op), and `dies-ok`/`lives-ok`/`throws-like` for exceptions.
- A failing assertion prints `not ok N` followed by diagnostic lines showing the
  expected and received values, so a red test tells you what went wrong.
- `plan N` up front fixes the expected count; alternatively call `done-testing` at the
  end to let the count be inferred.
- `subtest "name", { … }` groups related assertions and reports them as one.
- The output format is TAP (Test Anything Protocol), consumable by `prove` and other
  standard harnesses.
