---
title: Math functions
slug: math
status: full
order: 50
summary: Roots, absolute value, sign, the constants, and exp/log.
---

The common mathematical functions are built in as both subs and methods. They return
`Num` (floating point) where an exact result isn't rational.

## Roots and absolute value

```raku
say sqrt(2);
say abs(-5);
say (2 ** 0.5);
```
```output
1.4142135623730951
5
1.4142135623730951
```

`sqrt(2)` and `2 ** 0.5` agree — both are the `Num` square root.

## Sign

`.sign` returns `-1`, `0`, or `1`.

```raku
say (-3).sign;
say 3.sign;
say 0.sign;
```
```output
-1
1
0
```

## Constants

`pi`, `e`, and `tau` (= 2π) are built-in terms.

```raku
say pi;
say e;
say tau;
```
```output
3.141592653589793
2.718281828459045
6.283185307179586
```

## Exponential and logarithm

`exp` is eⁿ; `log` is the natural logarithm, with an optional second argument for
the base.

```raku
say exp(0);
say log(1);
say log(100, 10);
```
```output
1
0
2
```

## Notes

- These return `Num`, so results are IEEE 754 doubles — `sqrt(2)` shows all 17
  significant digits, unlike a `Rat`.
- Trigonometric functions (`sin`, `cos`, `tan` and their inverses) work in radians;
  `pi` and `tau` are there to convert.
- For integer-flavoured operations see [Arithmetic operators](/operators/arithmetic/)
  (`div`, `mod`, `gcd`, `lcm`).
