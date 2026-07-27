---
title: Strings
chapter: Basics
summary: Concatenate with ~, repeat with x, interpolate whole expressions, and call string methods.
---

Strings concatenate with `~` and repeat with `x`:

```raku
say 'Rak' ~ 'u';
say 'ha' x 3;
```
```output
Raku
hahaha
```

## Methods

Like every value in Raku, a string carries its own methods — call them with
the dot:

```raku
my $word = 'Camelia';
say $word.chars;
say $word.uc;
say $word.flip;
say 'the quick brown fox'.words.elems;
```
```output
7
CAMELIA
ailemaC
4
```

`.chars` counts characters, `.uc` upcases, `.flip` reverses, and `.words`
splits on whitespace (here we count the pieces with `.elems`).

## Interpolating expressions

Double quotes interpolate more than variables: a `{ ... }` block runs **any
code** and drops its result into the string.

```raku
my $n = 6;
say "$n squared is { $n ** 2 }.";
say "Today's word, backwards: { 'Raku'.flip }";
```
```output
6 squared is 36.
Today's word, backwards: ukaR
```

## Try it

Print your name in uppercase *and* reversed — `ANNA` stays suspiciously
readable both ways.

```raku exercise
my $name = 'Anna';
```

```solution
my $name = 'Anna';
say $name.uc;
say $name.uc.flip;
```
```output
ANNA
ANNA
```
