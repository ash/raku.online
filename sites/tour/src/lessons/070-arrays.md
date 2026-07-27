---
title: Arrays
chapter: Data structures
summary: Ordered collections with the @ sigil — index, slice, push, sort, join.
---

An array holds an ordered list of values and wears the `@` sigil. The
`<...>` quoting form makes a list of words without repeating quotes:

```raku
my @fruits = <apple banana cherry>;
say @fruits;
say @fruits.elems;
say @fruits[0];
say @fruits[*-1];
```
```output
[apple banana cherry]
3
apple
cherry
```

Indexing starts at 0, and `[*-1]` reads "the last one" — literally *the whole
count minus one*.

## Growing and shrinking

```raku
my @stack = <a b>;
@stack.push('c');
say @stack;
say @stack.pop;
say @stack;
```
```output
[a b c]
c
[a b]
```

## Slices, sorting, joining

Ask for several indices at once and you get a slice; `.sort` and `.reverse`
return new lists; `.join` glues elements into a string:

```raku
my @langs = <Raku Perl Python C>;
say @langs[0, 2];
say @langs.sort;
say @langs.join(', ');
```
```output
(Raku Python)
(C Perl Python Raku)
Raku, Perl, Python, C
```

## Try it

Given the shopping list, print it sorted, one item per line.

```raku exercise
my @shopping = <milk eggs bread apples>;
```

```solution
my @shopping = <milk eggs bread apples>;
for @shopping.sort {
    say $_;
}
```
```output
apples
bread
eggs
milk
```
