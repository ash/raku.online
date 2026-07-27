---
title: Conditionals
chapter: Control flow
summary: Branch with if/elsif/else and unless — no parentheses needed around the condition.
---

`if` runs a block when its condition is true. No parentheses are required
around the condition:

```raku
my $temperature = 35;
if $temperature > 30 {
    say 'A hot one.';
}
elsif $temperature > 15 {
    say 'Pleasant.';
}
else {
    say 'Bring a jacket.';
}
```
```output
A hot one.
```

`unless` is `if not` — handy when the negative reads more naturally. It takes
no `else`.

```raku
my $logged-in = False;
unless $logged-in {
    say 'Please sign in.';
}
```
```output
Please sign in.
```

Notice the variable name: identifiers in Raku may contain hyphens —
`$logged-in` is one name, and reads like English.

## The ternary and statement modifiers

`?? !!` picks between two expressions; and a *statement modifier* puts the
condition after the statement, which is pleasant for one-liners:

```raku
my $n = 7;
say $n %% 2 ?? 'even' !! 'odd';
say 'lucky!' if $n == 7;
```
```output
odd
lucky!
```

## Try it

Classify `$n`: print `positive`, `negative`, or `zero`.

```raku exercise
my $n = -5;
```

```solution
my $n = -5;
if $n > 0 {
    say 'positive';
}
elsif $n < 0 {
    say 'negative';
}
else {
    say 'zero';
}
```
```output
negative
```
