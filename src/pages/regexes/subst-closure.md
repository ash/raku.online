---
title: Substitution with a closure
slug: subst-closure
status: full
order: 32
summary: Replace each match with the result of running code on it.
---

The replacement side of `.subst` (or `s///`) can be a **closure** instead of a fixed
string — it runs per match and its return value is substituted. This turns
find-and-replace into find-and-transform.

## Compute the replacement

The block receives the match as `$/`; here each digit is doubled.

```raku
say "a1b2c3".subst(/\d/, -> $/ { $/ * 2 }, :g);
```
```output
a2b4c6
```

## A method as the replacement

A `Whatever`/method form works too — `*.tc` title-cases each matched word.

```raku
my $s = "hello world";
say $s.subst(/\w+/, *.tc, :g);
```
```output
Hello World
```

## Notes

- Inside the closure the match is the topic, so `$/`, `$0`, and `$<name>` are all
  available — replace `(\d+)` with `{ $0 + 1 }` to increment every number.
- This is the method form; the `s/pattern/{ code }/` operator form does the same with
  the closure in the replacement slot.
- Because the replacement is computed, one substitution can do context-dependent
  edits that a static string never could.
