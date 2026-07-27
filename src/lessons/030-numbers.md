---
title: Numbers
chapter: Basics
summary: Integers of any size, rational arithmetic where 0.1 + 0.2 == 0.3, and the usual operators.
---

Raku integers grow as large as they need to — no overflow, no special "big
integer" type to reach for:

```raku
say 2 ** 100;
```
```output
1267650600228229401496703205376
```

## Decimals are exact

Decimal literals are **rational numbers** (`Rat`), not binary floating point.
The classic floating-point surprise simply doesn't happen:

```raku
say 0.1 + 0.2;
say 0.1 + 0.2 == 0.3;
say 1/3 + 1/6;
```
```output
0.3
True
0.5
```

`1/3` really is one third, so a third plus a sixth is exactly a half.

## The usual operators

`+`, `-`, `*`, `/`, `**` (power), `%` (remainder), and `div` (integer
division). `%%` asks "is it evenly divisible?" and answers True or False:

```raku
say 17 % 5;
say 17 div 5;
say 10 %% 5;
say 10 ** -2;
```
```output
2
3
True
0.01
```

## Try it

Is the year 2100 divisible by 400? Print the answer with `%%`.

```raku exercise
my $year = 2100;
```

```solution
my $year = 2100;
say $year %% 400;
```
```output
False
```
