---
title: Where next
chapter: Beyond
summary: You've seen the core of the language — here's one last program and where to go from here.
---

That's the tour: values, control flow, data structures, functions with real
signatures, classes, roles, regexes, grammars, and junctions. One last
program, using a little of everything:

```raku
for 1..15 {
    say $_ %% 15 ?? 'FizzBuzz'
     !! $_ %% 3  ?? 'Fizz'
     !! $_ %% 5  ?? 'Buzz'
     !! $_;
}
```
```output
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
```

This editor — like every one in the tour — is a full Raku playground, so
stay and experiment as long as you like.

## Keep going

- [The playground](https://raku.online/) — the full-page editor this tour is built on, with sharable links.
- [The Raku course](https://course.raku.org/) — a complete course of the language, from the very basics to the details, with exercises.
- [The Raku++ specification](https://spec.raku.online/) — every feature of the interpreter behind these pages, documented with runnable examples.
- [raku.org](https://raku.org/) — the official home of the Raku language.
- [docs.raku.org](https://docs.raku.org/) — the official Raku documentation.
- [The interpreter itself](https://github.com/ash/rakupp) — Raku++, the C++ implementation of Raku that compiled to WebAssembly to run this tour.

## One empty editor, for the road

```raku exercise
# Yours.
```
