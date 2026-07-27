---
title: Hashes
chapter: Data structures
summary: Key–value maps with the % sigil — look up with <...>, add pairs, test existence, iterate.
---

A hash maps keys to values and wears the `%` sigil. Build one from pairs
(`key => value`) and look values up with `<...>`:

```raku
my %age = alice => 30, bob => 25;
say %age<alice>;
say %age<bob>;
```
```output
30
25
```

For a key held in a variable, use curly braces instead: `%age{$name}`.

```raku
my %age = alice => 30, bob => 25;
my $who = 'bob';
say %age{$who};
```
```output
25
```

## Adding, testing, counting

Assign to a new key to add it. The `:exists` adverb asks whether a key is
present:

```raku
my %age = alice => 30;
%age<carol> = 28;
say %age.elems;
say %age<carol>:exists;
say %age<dave>:exists;
```
```output
2
True
False
```

## Iterating

A hash has no fixed order, so sort before you print. Each element is a `Pair`
with `.key` and `.value`:

```raku
my %population = tokyo => 37, delhi => 32, paris => 11;
for %population.sort -> $p {
    say "{$p.key}: {$p.value} million";
}
```
```output
delhi: 32 million
paris: 11 million
tokyo: 37 million
```

## Try it

Count the letters of `banana` into a hash, then print the counts in sorted
order. (Hint: `'banana'.comb` gives the list of letters, and `%count{$_}++`
counts one.)

```raku exercise
my %count;
for 'banana'.comb {
}
```

```solution
my %count;
for 'banana'.comb {
    %count{$_}++;
}
for %count.sort -> $p {
    say "{$p.key}: {$p.value}";
}
```
```output
a: 3
b: 1
n: 2
```
