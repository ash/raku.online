---
title: Laziness — lazy, eager & infinite lists
slug: lazy
status: full
order: 50
summary: Work with lists that compute elements on demand, including infinite ones.
---

Many Raku list producers are **lazy**: they compute elements only as you ask for
them. That makes infinite lists ordinary values — you can define "all the squares" or
"all the primes" and then take just the first few. A lazy list does no work until
something pulls on it, so an unbounded source never runs away.

## Taking from an infinite list

An infinite range like `1..Inf` (or `1..∞`) is lazy; mapping or grepping over it stays
lazy, so indexing or `.head` only forces the elements you actually read.

```raku
my @squares = (1..Inf).map(* ** 2);
say @squares[^5];
say (1..Inf).grep(*.is-prime).head(5);
```
```output
(1 4 9 16 25)
(2 3 5 7 11)
```

Neither line computes more than it needs: `@squares[^5]` forces five squares, and
`.head(5)` stops the prime filter after the fifth prime.

## Testing laziness — `.is-lazy`

`.is-lazy` reports whether a list still has unrealised, on-demand elements. A bounded
range knows its size and is *not* lazy; an unbounded one is.

```raku
say (1..10).is-lazy;
say (1..Inf).is-lazy;
```
```output
False
True
```

## Finding without a bound

Because the search is lazy, `.first` can scan an infinite list and stop at the first
hit — no upper limit needed.

```raku
say (1..Inf).first(* > 1000);
```
```output
1001
```

## Self-referential sequences

The sequence operator `...` (see [The sequence operator](/operators/sequence/))
builds a lazy series from a closure — even one that reads its own earlier terms, like
Fibonacci — and you take a prefix the same way.

```raku
my \fib = (1, 1, * + * ... *);
say fib[^10];
```
```output
(1 1 2 3 5 8 13 21 34 55)
```

## Notes

- `eager` forces a lazy list fully into memory — use it when you *want* all the work
  done now (and never on a truly infinite list, which would loop forever).
- Indexing (`@a[100]`), `.head(n)`, `.first`, and `for` all pull lazily; `.elems`,
  `.sort`, `.reverse`, and `say @a` (the whole list) force evaluation.
- Ranges (`1..Inf`) and the sequence operator (`1, 2, 4 ... *`) are the common lazy
  sources; `gather`/`take` ([gather / take](/control/gather-take/)) produces
  values on demand too.
- `.head`/`.tail` and slices are the safe way to look at an infinite list — printing
  the whole thing would never finish.
