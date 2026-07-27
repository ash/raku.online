---
title: Variables
chapter: Basics
summary: Declare variables with my; scalars use the $ sigil and interpolate into strings.
---

Variables are declared with `my`. A single value — a number, a string, anything
that is *one thing* — lives in a variable with the `$` sigil:

```raku
my $name = 'Alice';
my $age = 30;
say $name;
say $age;
```
```output
Alice
30
```

The sigil stays part of the name: it's `$name` when you declare it, assign to
it, and read it. (Raku also has `@` for arrays and `%` for hashes — those get
their own lessons soon.)

## Interpolation

Double-quoted strings interpolate variables directly:

```raku
my $name = 'Alice';
say "Hello, $name!";
say 'Hello, $name!';
```
```output
Hello, Alice!
Hello, $name!
```

Single quotes keep the text literal — a useful pair to remember.

## Variables vary

Assignment with `=` replaces the value; operators like `+=` and `~=` (string
append) update it in place.

```raku
my $count = 10;
$count = $count + 5;
$count += 5;
say $count;

my $word = 'Ra';
$word ~= 'ku';
say $word;
```
```output
20
Raku
```

## Try it

Declare a variable holding your favourite language and print
`I like <language>!` using interpolation.

```raku exercise
my $language = ...;
```

```solution
my $language = 'Raku';
say "I like $language!";
```
```output
I like Raku!
```
