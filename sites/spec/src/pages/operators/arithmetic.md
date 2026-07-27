---
title: Arithmetic operators
slug: arithmetic
status: full
order: 20
summary: The numeric infixes — + - * / % ** div mod — and the types they return.
---

The arithmetic operators work across the whole numeric tower. Division of integers
yields an exact `Rat` (see [Rational literals](/literals/rationals/)), not a
truncated integer.

## The basic set

```raku
say 7 + 3;
say 7 - 3;
say 7 * 3;
say 7 / 2;
say 7 ** 2;
```
```output
10
4
21
3.5
49
```

## Modulus and integer division

`%` is modulus, `**` is exponentiation, and `div`/`mod` are the integer-only
counterparts of `/` and `%`.

```raku
say 7 % 3;
say 7 div 2;
say 7 mod 3;
```
```output
1
3
1
```

## gcd and lcm

Greatest common divisor and least common multiple are built-in infix operators.

```raku
say 12 gcd 18;
say 4 lcm 6;
```
```output
6
12
```

## Notes

- `/` never truncates: `7 / 2` is `3.5` (a `Rat`), and `6 / 3` is `2` but still a
  `Rat`. Use `div` for floor integer division.
- `%` gives the mathematical modulo, taking the sign of the divisor: `-7 % 3` is
  `2`, not `-1`.
- Exponentiation `**` is right-associative: `2 ** 2 ** 3` is `2 ** 8` = `256`, not
  `4 ** 3`.
