---
title: map, grep and friends
chapter: Functions
summary: Transform lists with map, filter with grep, fold with [+] — and chain it all with dots.
---

`map` transforms every element; `grep` keeps the ones that match. The `*`
(*whatever star*) builds a tiny function in place:

```raku
say (1..10).map(* ** 2);
say (1..10).grep(* %% 2);
```
```output
(1 4 9 16 25 36 49 64 81 100)
(2 4 6 8 10)
```

`* ** 2` reads "whatever, squared"; `* %% 2` reads "whatever, divisible by 2".

## Chains

Because each method returns a new list, calls chain left to right into little
pipelines:

```raku
my @words = <pearl onion camelia butterfly bee>;
say @words.grep(*.chars > 5).map(*.uc).sort;
say @words.sort(*.chars).join(' < ');
```
```output
(BUTTERFLY CAMELIA)
bee < pearl < onion < camelia < butterfly
```

That second line sorts by a *key* — here, word length.

## Reduction

Put an operator in `[...]` and it folds a whole list down to one value:

```raku
say [+] 1..100;
say [*] 1..10;
say [max] 3, 41, 9, 26;
```
```output
5050
3628800
41
```

## Try it

In one chain: take 1..20, keep the odd numbers, square them, and sum the lot.

```raku exercise
say ...;
```

```solution
say [+] (1..20).grep(* % 2).map(* ** 2);
```
```output
1330
```
